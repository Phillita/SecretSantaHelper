class ApplicationMailer < ActionMailer::Base
  require 'mail'
  default from: 'app.helper@gmail.com'
  layout 'mailer'
end
