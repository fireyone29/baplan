require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Baplan
  # Our Rails Application Class :)
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those
    # specified here.  Application configuration should go into files
    # in config/initializers -- all .rb files in that directory are
    # automatically loaded.
    config.time_zone = ENV['TIMEZONE'] if ENV.key?('TIMEZONE')

    config.action_controller.per_form_csrf_tokens = true
    config.action_controller.forgery_protection_origin_check = true
    config.active_record.belongs_to_required_by_default = true
    # Configure SSL options to enable HSTS with subdomains. Previous
    # versions had false.
    Rails.application.config.ssl_options = { hsts: { subdomains: true } }

    # Devise should not use secure cookies by default.
    config.devise_rememberable_opt = {}
  end
end
