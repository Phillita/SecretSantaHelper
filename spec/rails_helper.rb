# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'simplecov'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'

SimpleCov.start

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Choose one or more libraries:
    with.library :rails
  end
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers

  # headless chrome support
  # Capybara.register_driver :chrome do |app|
  #   Capybara::Selenium::Driver.new(app, browser: :chrome)
  # end
  #
  # Capybara.register_driver :headless_chrome do |app|
  #   capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
  #     chromeOptions: { args: %w(headless disable-gpu) }
  #   )
  #
  #   Capybara::Selenium::Driver.new app, browser: :chrome, desired_capabilities: capabilities
  # end

  # Capybara.javascript_driver = :headless_chrome

  Capybara.javascript_driver = :webkit

  Capybara::Webkit.configure do |webkit_config|
    # Enable debug mode. Prints a log of everything the driver is doing.
    webkit_config.debug = false

    # By default, requests to outside domains (anything besides localhost) will
    # result in a warning. Several methods allow you to change this behavior.

    # Silently return an empty 200 response for any requests to unknown URLs.
    # webkit_config.block_unknown_urls

    # Allow pages to make requests to any URL without issuing a warning.
    # webkit_config.allow_unknown_urls

    # Allow a specific domain without issuing a warning.
    # webkit_config.allow_url("example.com")

    # Allow a specific URL and path without issuing a warning.
    # webkit_config.allow_url("example.com/some/path")

    # Wildcards are allowed in URL expressions.
    # webkit_config.allow_url("*.example.com")

    # Silently return an empty 200 response for any requests to the given URL.
    # webkit_config.block_url("example.com")

    # Timeout if requests take longer than 5 seconds
    webkit_config.timeout = 5

    # Don't raise errors when SSL certificates can't be validated
    webkit_config.ignore_ssl_errors

    # Don't load images
    webkit_config.skip_image_loading

    # Use a proxy
    # webkit_config.use_proxy(
    #   host: "example.com",
    #   port: 1234,
    #   user: "proxy",
    #   pass: "secret"
    # )

    # Raise JavaScript errors as exceptions
    webkit_config.raise_javascript_errors = true
  end

  # headless chrome support
  # Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  #   driver.browser.save_screenshot(path)
  # end
  # Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  #   driver.browser.save_screenshot(path)
  # end

  Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
    "screenshot_#{example.description.gsub(' ', '-').gsub(/^.*\/spec\//,'')}"
  end
  Capybara::Screenshot.prune_strategy = :keep_last_run

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end
