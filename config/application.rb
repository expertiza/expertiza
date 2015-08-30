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

    #setting the default ssl setting to false
    config.use_ssl = false

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    #When you are ready, you can opt into the new behavior and remove the deprecation warning by adding following configuration to your config/application.rb
    config.active_record.raise_in_transactional_callbacks = true

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation, :password, :password_confirmation]

    config.active_record.whitelist_attributes = false

    config.autoload_paths += Dir[Rails.root.join('lib', '{**}')]

    config.react.addons = true

    config.assets.paths << Rails.root.join('vendor', 'assets', 'components')

    # Bower asset paths
    root.join('vendor', 'assets', 'components').to_s.tap do |bower_path|
      config.sass.load_paths << bower_path
      config.assets.paths << bower_path
    end
    # Precompile Bootstrap fonts
    config.assets.precompile << %r(bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff2?)$)
    # Minimum Sass number precision required by bootstrap-sass
    ::Sass::Script::Value::Number.precision = [8, ::Sass::Script::Value::Number.precision].max

  end
end
