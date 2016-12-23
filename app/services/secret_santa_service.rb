module SecretSanta
  def make_magic(test = false)
    names = {
      brady: { partner: :ryan, email: 'brady_a_p@hotmail.com' },
      ryan: { partner: :brady, email: 'rpf770@mun.ca' },
      luke: { partner: :none, email: 'stingluke4@hotmail.com' },
      greg: { partner: :none, email: 'Stinggreg12@icloud.com' },
      lauren: { partner: :mike, email: 'lauren_fraser98@hotmail.com' },
      mike: { partner: :lauren, email: 'fitzyfour12@hotmail.com' },
      jaylynn: { partner: :none, email: 'jaylynn.rossrogers@lkdsb.com' }
    }
    # names = {
    #   chelsea: { partner: :none, email: 'chelsea@protech.ws' },
    #   dania: { partner: :none, email: 'daniaphillips@gmail.com' },
    #   tayler: { partner: :kara, email: 'taylerphillips20@gmail.com' },
    #   kara: { partner: :tayler, email: 'kara_4291@hotmail.com' },
    #   brady: { partner: :ryan, email: 'brady_a_p@hotmail.com' },
    #   ryan: { partner: :brady, email: 'rpf770@mun.ca' }
    # }
    matches = find_matches(names)
    if test
      test_output_matches(matches)
    else
      print_matches(matches)
      mail_matches(matches)
      cleanup_files(matches)
    end
  end

  private

  def find_matches(names)
    srand
    used = []
    names_arr = names.keys
    names_arr.shuffle.each do |name|
      loop do
        secret_match = names_arr[rand(names_arr.size)]
        if names[secret_match][:secret].nil? &&
           names[secret_match][:partner] != name &&
           secret_match != name &&
           !used.include?(name)
          names[secret_match][:secret] = name
          used << name
        end
        break if names[secret_match][:secret] == name
      end
    end
    names
  end

  def print_matches(names, dir = 'SecretSanta')
    require 'fileutils'

    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    names.each do |k, v|
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

  def mail_matches(names)
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

    names.each do |k, v|
      next if v[:email].empty?
      puts "Sending mail to: #{v[:email]}"

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

  def cleanup_files(names)
    names.each do |_k, v|
      File.delete(v[:file])
    end
  end

  def test_output_matches(names)
    names.each { |k, v| puts "#{k.to_s.capitalize} gives to #{v[:secret].to_s.capitalize} and the match is a #{v[:partner] != v[:secret] ? 'success!' : 'failure.'}" }
  end
end
