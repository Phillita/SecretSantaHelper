# frozen_string_literal: true

require 'securerandom'

class SecretSantaService
  attr_reader :secret_santa, :matches
  MAX_LOOP = 100

  def initialize(secret_santa)
    @secret_santa = secret_santa
    @retry_count = 0
  end

  def make_magic!
    ActiveRecord::Base.transaction do
      reset
      create_matches
      @secret_santa.reload
      finishing_touches unless @secret_santa.test?
      true
    end
  rescue => ex
    Rails.logger.error ex.message + "\n" + ex.backtrace.join("\n")
    false
  end

  private

  def create_matches
    @secret_santa.secret_santa_participants.each do |participant|
      secret_santa_match = build_match(participant)
      unless secret_santa_match.match
        raise SantaExceptions::InfiniteLoopError, "No one can be matched to #{participant.name}"
      end
      secret_santa_match.save!
    end
  rescue SantaExceptions::InfiniteLoopError
    raise 'Hit infinite loop in matching. Possibly due to complex exception matching.' if @retry_count > 3
    Rails.logger.info "\n::Failed to match all participants. Retrying (#{@retry_count += 1})...\n"
    reset
    retry
  end

  def build_match(participant)
    @secret_santa.secret_santa_participant_matches
                 .build(
                   test: @secret_santa.test?,
                   match: find_match(participant),
                   secret_santa_participant: participant
                 )
  end

  def find_match(participant)
    @secret_santa.secret_santa_participants
                 .where(
                   SecretSantaParticipant[:id].not_in(
                     (exceptions(participant) + matched) << participant.id
                   )
                 ).sample
  end

  def exceptions(participant)
    participant.secret_santa_participant_exceptions.pluck(:exception_id)
  end

  def matched
    @secret_santa.secret_santa_participant_matches.pluck(:match_id)
  end

  def reset
    @secret_santa.secret_santa_participant_matches.each(&:destroy)
    @secret_santa.reload
  end

  def finishing_touches
    print_matches(@secret_santa.secret_santa_participant_matches) if @secret_santa.send_file?
    mail_matches(@secret_santa.secret_santa_participant_matches) if @secret_santa.send_email?
    cleanup_files(@secret_santa.secret_santa_participant_matches) if @secret_santa.send_file?
    @secret_santa.update_attribute(:last_run_on, Time.zone.now)
  end

  def print_matches(matches, dir = Rails.root.join('tmp/secret_santa'))
    require 'fileutils'
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    matches.each do |match|
      filename = parse_liquid(@secret_santa.filename, liquid_options(match))
      file_content = parse_liquid(@secret_santa.file_content, liquid_options(match))
      filepath = "#{dir}/#{filename}.txt"
      File.open(filepath, 'w') { |file| file.write(file_content) }
      match.file = filepath
    end
  end

  def liquid_options(match)
    {
      'Giver' => match.giver_name,
      'Receiver' => match.name,
      'SecretSanta' => @secret_santa.name
    }
  end

  def mail_matches(matches)
    matches.each do |match|
      SecretSantaMailer.participant(match.secret_santa_participant_id, match.name, match[:file]).deliver_now
      sleep 1
    end
  end

  def cleanup_files(matches)
    matches.each do |match|
      File.delete(match.file)
    end
  end

  def parse_liquid(text, template_options = {})
    template = Liquid::Template.parse(text)
    template.render(template_options)
  end
end
