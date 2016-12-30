class SecretSantaService
  attr_reader :secret_santa, :matches

  def initialize(secret_santa)
    @secret_santa = secret_santa
  end

  def make_magic!
    @matches = find_matches(@secret_santa.to_h)
    unless @secret_santa.test?
      print_matches(@matches) if @secret_santa.send_file?
      mail_matches(@matches) if @secret_santa.send_email?
      cleanup_files(@matches) if @secret_santa.send_file?
    end
    true
  rescue => ex
    Rails.logger.error ex.message
    false
  end

  private

  def find_matches(santa_hsh)
    srand
    used = []
    id_arr = santa_hsh.keys
    id_arr.shuffle.each do |id|
      loop do
        secret_id = id_arr[rand(id_arr.size)]
        if santa_hsh[secret_id][:secret].nil? &&
           !santa_hsh[secret_id][:exceptions].include?(id) &&
           secret_id != id &&
           !used.include?(id)
          santa_hsh[secret_id][:secret] = { id: id, name: santa_hsh[id][:name] }
          used << id
        end
        break if santa_hsh[secret_id].fetch(:secret, {}).fetch(:id, nil) == id
      end
    end
    santa_hsh
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
    require 'mail'

    options = {
      address: 'smtp.gmail.com',
      port: 587,
      user_name: 'santas.app.helper@gmail.com',
      password: 'LamNmXn6nZKa6PTAPR',
      authentication: 'plain',
      enable_starttls_auto: true
    }

    Mail.defaults do
      delivery_method :smtp, options
    end

    matches.each do |k, v|
      next if v[:email].empty?
      Rails.logger.info "Sending mail to: #{v[:email]}"

      mail = Mail.new
      mail.to v[:email]
      mail.from 'Secret Santa App <santas.app.helper@gmail.com>'
      mail.subject 'Secret Santa - Shhhhh'
      mail.body "#{k.to_s.capitalize} attached is your Secret Santa.\nKeep it a secret!!"
      mail.add_file(v[:file])
      mail.deliver
      sleep 1
    end
  end

  def cleanup_files(matches)
    matches.each do |_k, v|
      File.delete(v[:file])
    end
  end
end
