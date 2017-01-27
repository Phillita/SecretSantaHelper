require 'securerandom'

class SecretSantaService
  attr_reader :secret_santa, :matches
  MAX_LOOP = 100

  def initialize(secret_santa)
    @secret_santa = secret_santa
    @retry_count = 0
  end

  def make_magic!
    matches = find_matches(@secret_santa.to_h)
    save_matches(matches)
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

  def find_matches(santa_hsh)
    used = []
    id_arr = santa_hsh.keys
    id_arr.shuffle.each do |id|
      loop_count = 0
      loop do
        available_ids = santa_hsh.reject { |k, v| used.include?(k) || v[:exceptions].include?(id) || k == id }.keys
        element_index = SecureRandom.random_number(available_ids.size)
        fail SantaExceptions::InfiniteLoopError, "No one can be matched to #{santa_hsh[id][:name]}" if available_ids.empty?
        secret_id = available_ids[element_index]

        Rails.logger.info "Trying to match #{santa_hsh[id][:name]} (#{id}) with #{santa_hsh[secret_id][:name]} (#{secret_id}).\n"
        Rails.logger.info "#{element_index}          #{available_ids}          #{used}"

        if santa_hsh[id][:secret].nil? &&
           !santa_hsh[id][:exceptions].include?(secret_id) &&
           !used.include?(secret_id) &&
           secret_id != id
          santa_hsh[id][:secret] = { id: secret_id, name: santa_hsh[secret_id][:name] }
          used << secret_id

          Rails.logger.info "::Matched #{santa_hsh[id][:name]} with #{santa_hsh[id][:secret][:name]}."
        end
        loop_count += 1
        Rails.logger.info "Loop Count: #{loop_count}\n\n"
        break if santa_hsh[id].fetch(:secret, {}).fetch(:id, nil) == secret_id
        fail SantaExceptions::InfiniteLoopError, 'Failed matching' if loop_count >= id_arr.size + MAX_LOOP
      end
    end
    santa_hsh
  rescue SantaExceptions::InfiniteLoopError
    if @retry_count < 3
      Rails.logger.warn "Hit infinite loop in matching:\n#{santa_hsh}\nRetrying (#{@retry_count})"
      reset(santa_hsh)
      retry
    else
      raise 'Hit infinite loop in matching too many times. Possibly due to complex exception matching.'
    end
  end

  def reset(santa_hsh)
    santa_hsh.each do |_k, v|
      v.delete(:secret)
    end
  end

  def save_matches(matches)
    matches.each do |id, match|
      secret_santa_participant_match = @secret_santa.secret_santa_participant_matches.where(secret_santa_participant_id: id).first_or_initialize
      secret_santa_participant_match.test = @secret_santa.test?
      secret_santa_participant_match.match_id = match[:secret][:id]
      secret_santa_participant_match.save
    end
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
      SecretSantaMailer.participant(match.secret_santa_participant_id, match.name, match[:file]).deliver
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
