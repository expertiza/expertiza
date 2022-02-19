Expertiza::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false
  # config.serve_static_assets = false
  # config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  host = '152.7.98.82:8080'
  config.action_mailer.default_url_options = { host: '152.7.98.82:8080', protocol: 'http' }
  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  # config.active_record.whitelist_attributes = false # need protected_attributes gem

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 25,
    domain: 'gmail.com',
    user_name: 'expertiza.debugging@gmail.com',
    password: 'dt2DR0Hhf',
    authentication: 'plain',
    enable_starttls_auto: true
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
  # Print development logs
  config.log_level = :error

  config.log_tags = %i[remote_ip uuid]

  config.log_formatter = proc do |s, ts, pg, msg|
    if msg.is_a?(LoggerMessage)
      "TST=[#{ts}] SVT=[#{s}] PNM=[#{pg}] OIP=[#{msg.oip}] RID=[#{msg.req_id}] CTR=[#{msg.generator}] UID=[#{msg.unity_id}] MSG=[#{filter(msg.message)}]\n"
    else
      "TST=[#{ts}] SVT=[#{s}] PNM=[#{pg}] OIP=[] RID=[] CTR=[] UID=[] MSG=[#{filter(msg)}]\n"
    end
  end

  def filter(msg)
    msg.tr("\n", ' ')
  end

  config.action_view.logger = nil

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.react.variant = :development
  config.active_record.logger = nil
  # Line 63-69 are for 'bullet' gem initialization.
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = false
    Bullet.bullet_logger = false
    Bullet.console = false
    Bullet.rails_logger = false
  end
end
