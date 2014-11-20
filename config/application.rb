require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Expertiza
  class Application < Rails::Application
    # Do not access db or load models while precompiling
    config.assets.initialize_on_precompile = false

    config.time_zone = 'UTC'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation, :password, :password_confirmation]

    config.active_record.whitelist_attributes = false

    config.autoload_paths += Dir[Rails.root.join('lib', '{**}')]
  end
end
