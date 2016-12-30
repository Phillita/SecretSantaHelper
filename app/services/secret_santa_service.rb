require 'securerandom'

class SecretSantaService
  attr_reader :secret_santa, :matches
  MAX_LOOP = 100

  def initialize(secret_santa)
    @secret_santa = secret_santa
    @retry_count = 0
  end

  def make_magic!
    @matches = find_matches(@secret_santa.to_h)
    unless @secret_santa.test?
      print_matches(@matches) if @secret_santa.send_file?
      mail_matches(@matches) if @secret_santa.send_email?
      cleanup_files(@matches) if @secret_santa.send_file?
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

  def print_matches(matches, dir = 'SecretSanta')
    require 'fileutils'

    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    matches.each do |k, v|
      filepath = "#{dir}/#{k.to_s.capitalize}.txt"
      File.open(filepath, 'w') do |file|
        file.write("Your Secret Santa is:\n")
        file.write('==> ' + v[:secret].to_s + ' <==')
        file.write("\n\n")
        file.write("Brought to you by\n")
        file.write("The wonderful\n")
        file.write('Santa\'s Little App Helper')
      end
      v[:file] = filepath
    end
  end

  def mail_matches(matches)
    # require 'mail'
    #
    # options = {
    #   address: 'smtp.gmail.com',
    #   port: 587,
    #   user_name: 'santas.app.helper@gmail.com',
    #   password: 'LamNmXn6nZKa6PTAPR',
    #   authentication: 'plain',
    #   enable_starttls_auto: true
    # }
    #
    # Mail.defaults do
    #   delivery_method :smtp, options
    # end
    #
    # matches.each do |k, v|
    #   next if v[:email].empty?
    #   Rails.logger.info "Sending mail to: #{v[:email]}"
    #
    #   mail = Mail.new
    #   mail.to v[:email]
    #   mail.from 'Secret Santa App <santas.app.helper@gmail.com>'
    #   mail.subject 'Secret Santa - Shhhhh'
    #   mail.body "#{k.to_s.capitalize} attached is your Secret Santa.\nKeep it a secret!!"
    #   mail.add_file(v[:file])
    #   mail.deliver
    #   sleep 1
    # end
  end

  def cleanup_files(matches)
    matches.each do |_k, v|
      File.delete(v[:file])
    end
  end
end
