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
    reset
    find_matches
    unless @secret_santa.test?
      print_matches(@secret_santa.secret_santa_participant_matches) if @secret_santa.send_file?
      mail_matches(@secret_santa.secret_santa_participant_matches) if @secret_santa.send_email?
      cleanup_files(@secret_santa.secret_santa_participant_matches) if @secret_santa.send_file?
      @secret_santa.update_attribute(:last_run_on, Time.zone.now)
    end
    true
  rescue => ex
    Rails.logger.error ex.message
    Rails.logger.error ex.backtrace.join("\n")
    false
  end

  private

  def find_matches
    @secret_santa.secret_santa_participants.each do |participant|
      exs = participant.secret_santa_participant_exceptions.pluck(:exception_id) << participant.id
      match = @secret_santa.secret_santa_participants.where(SecretSantaParticipant[:id].not_in(exs)).sample
      raise "No one can be matched to #{participant.name}" unless match
      Rails.logger.info "\n::Matched #{participant.name} with #{match.name}.\n"
      secret_santa_participant_match = @secret_santa.secret_santa_participant_matches.where(secret_santa_participant_id: participant.id).first_or_initialize
      secret_santa_participant_match.test = @secret_santa.test?
      secret_santa_participant_match.match_id = match.id
      secret_santa_participant_match.save!
    end
  rescue SantaExceptions::InfiniteLoopError
    raise 'Hit infinite loop in matching. Possibly due to complex exception matching.' if @retry_count > 3
    reset
    @retry_count += 1
    retry
  rescue => ex
    Rails.logger.warn ex.message
    raise
  end

  def reset
    @secret_santa.secret_santa_participant_matches.destroy_all
  end

  def print_matches(matches, dir = Rails.root.join('tmp/secret_santa'))
    require 'fileutils'

    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    matches.each do |match|
      liquid_options = {
        'Giver' => match.giver_name,
        'Receiver' => match.name,
        'SecretSanta' => @secret_santa.name
      }
      filename = parse_liquid(@secret_santa.filename, liquid_options)
      file_content = parse_liquid(@secret_santa.file_content, liquid_options)
      filepath = "#{dir}/#{filename}.txt"
      File.open(filepath, 'w') { |file| file.write(file_content) }
      match.file = filepath
    end
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
