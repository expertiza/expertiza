require File.expand_path('boot', __dir__)
require 'net/https'
require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Expertiza
  class Application < Rails::Application
    # This is a logger to capture internal server errors that do not show up when testing javascript. Look in log/diagnostic.txt when there is a 500 error.
    if Rails.env == 'test'
      require File.expand_path('diagnostic.rb', __dir__)
      config.middleware.use(MyApp::DiagnosticMiddleware)
    end
    # Do not access db or load models while precompiling
    config.assets.initialize_on_precompile = false
    config.time_zone = 'UTC'
    # setting the default ssl setting to false
    config.use_ssl = false
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
    #When you are ready, you can opt into the new behavior and remove the deprecation warning by adding following configuration to your config/application.rb
    #config.active_record.raise_in_transactional_callbacks = true
    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation, :password, :password_confirmation]
    # config.active_record.whitelist_attributes = false # need protected_attributes gem
    config.autoload_paths << Rails.root.join('lib', '{**}')
    config.eager_load_paths << Rails.root.join('lib')
    config.react.addons = true
    config.assets.paths << Rails.root.join('vendor', 'assets', 'components')
    config.cache_store = :redis_store, "redis://#{ENV.fetch('REDIS_HOST', 'localhost')}:6379/0/cache", { raise_errors: false }
    # Bower asset paths
    root.join('vendor', 'assets', 'components').to_s.tap do |bower_path|
      config.sass.load_paths << bower_path
      config.assets.paths << bower_path
    end
    # Precompile Bootstrap fonts
    config.assets.precompile << %r{bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff2?)$}
    # Minimum Sass number precision required by bootstrap-sass
    ::Sass::Script::Value::Number.precision = [8, ::Sass::Script::Value::Number.precision].max
  end

  module Recaptcha
    class Application < Rails::Application
      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration should go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded.

      # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
      # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
      # config.time_zone = 'Central Time (US & Canada)'

      # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
      # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]

      # Languages for the application
      config.i18n.available_locales = %i[en_US hi_IN]
      config.i18n.default_locale = :en_US # english

      # Do not swallow errors in after_commit/after_rollback callbacks.
      # config.active_record.raise_in_transactional_callbacks = true
    end
  end
end
