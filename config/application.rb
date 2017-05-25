require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Baplan
  # Our Rails Application Class :)
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those
    # specified here.  Application configuration should go into files
    # in config/initializers -- all .rb files in that directory are
    # automatically loaded.

    config.action_controller.per_form_csrf_tokens = true
    config.action_controller.forgery_protection_origin_check = true
    config.active_record.belongs_to_required_by_default = true
    config.ssl_options = { hsts: { subdomains: true } }

    # Devise should not use secure cookies by default.
    config.devise_rememberable_opt = {}
  end
end
