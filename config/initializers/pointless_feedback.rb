PointlessFeedback.setup do |config|
  # ==> Feedback Configuration
  # Configure the topics for the user to choose from on the feedback form
  config.message_topics = ['Question', 'Application Idea', 'General Feedback', 'Error on page', 'Other']

  # ==> Email Configuration
  # Configure feedback email properties (disabled by default)
  # Variables needed for emailing feedback
  config.email_feedback = true
  config.send_from_submitter       = false
  config.from_email                = 'feedback@apphelper.com'
  config.to_emails                 = [Rails.application.secrets.feedback_to_email]
  config.google_captcha_site_key   = Rails.application.secrets.google_captcha_site_key
  config.google_captcha_secret_key = Rails.application.secrets.google_captcha_secret_key
end
