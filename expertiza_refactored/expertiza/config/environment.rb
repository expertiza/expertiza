# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  if RAILS_ENV == 'production' and RUBY_PLATFORM !~ /mswin|mingw/ # Don't check on Windows, because there's no "which" command to check
    raise 'dot executable missing - install graphviz' if %x(which dot).to_s.empty?
  end

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  config.action_controller.session = {
       :key => 'pg_session',
       :secret => '3d70fee70cddd63552e8dd6ae6c788060af8fb015da5fef83d368abf37aa10c112d842d7c038420845109147779552cdd687ec4e2034cec3046dc439d8a468e'
  }

  config.action_controller.session_store = :active_record_store
  
  if RAILS_ENV == 'production'
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address => "smtp.ncsu.edu",
      :port => 25,
      :domain => "localhost"
    }
  end
  if RAILS_ENV == 'test'
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address => "smtp.ncsu.edu",
      :port => 25,
      :domain => "localhost"
    }
  end
end
