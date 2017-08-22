# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SecretSantaApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # ActiveSupport.halt_callback_chains_on_return_false = false

    # When using Ruby 2.4, you can preserve the timezone of the receiver when calling to_time.
    # ActiveSupport.to_time_preserves_timezone = false
  end
end
