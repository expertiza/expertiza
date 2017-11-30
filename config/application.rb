require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Expertiza
  class Application < Rails::Application

    #This is a logger to capture internal server errors that do not show up when testing javascript. Look in log/diagnostic.txt when there is a 500 error.
    if Rails.env == 'test'
      require File.expand_path("../diagnostic.rb", __FILE__)
      config.middleware.use(MyApp::DiagnosticMiddleware)
    end
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
    config.cache_store = :redis_store, "redis://#{ENV.fetch('REDIS_HOST', 'localhost')}:6379/0/cache", { raise_errors: false }
    # Bower asset paths
    root.join('vendor', 'assets', 'components').to_s.tap do |bower_path|
      config.sass.load_paths << bower_path
      config.assets.paths << bower_path
    end
    # Precompile Bootstrap fonts
    config.assets.precompile << %r(bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff2?)$)
    # Minimum Sass number precision required by bootstrap-sass
    ::Sass::Script::Value::Number.precision = [8, ::Sass::Script::Value::Number.precision].max

    config.github_oauth_app_secrets = {
      client_id: ENV["GITHUB_OAUTH_CLIENT_ID"],
      client_secret: ENV["GITHUB_OAUTH_CLIENT_SECRET"]
    }

    config.github_tokens = {
      github_token: ENV["GITHUB_TOKEN"],
      ncsu_token: ENV["NCSU_TOKEN"]
    }

    config.github_throttle = 5

    config.github_sources = [
      { REGEX: /http[s]{0,1}:\/\/github\.com\/(?'username'[^[\/]]+)\/(?'reponame'[^\/]+)\/pull\/(?'prnum'\d+)/,
        GRAPHQL: "https://api.github.com/graphql",
        API: "https://api.github.com/repos",
        FUNCTION: :fetch_pr_commits_data,
        TOKEN: config.github_tokens[:github_token]
      },
      { REGEX: /http[s]{0,1}:\/\/github\.com\/(?'username'[^[\/]]+)\/(?'reponame'[^\/]+)/,
        GRAPHQL: "https://api.github.com/graphql",
        API: "https://api.github.com/repos",
        FUNCTION: :fetch_project_data,
        TOKEN: config.github_tokens[:github_token]
      },
      { REGEX: /http[s]{0,1}:\/\/github\.ncsu\.edu\/(?'username'[^[\/]]+)\/(?'reponame'[^\/]+)\/pull\/(?'prnum'\d+)/,
        GRAPHQL: "https://github.ncsu.edu/api/graphql",
        API: "https://github.ncsu.edu/api/v3/repos",
        FUNCTION: :fetch_pr_commits_data,
        TOKEN: config.github_tokens[:ncsu_token]
      },
      { REGEX: /http[s]{0,1}:\/\/github\.ncsu\.edu\/(?'username'[^[\/]]+)\/(?'reponame'[^\/]+)/,
        GRAPHQL: "https://github.ncsu.edu/api/graphql",
        API: "https://github.ncsu.edu/api/v3/repos",
        FUNCTION: :fetch_project_data,
        TOKEN: config.github_tokens[:ncsu_token]
      }
    ]

    config.trello_token = {
      trello_token: ENV["TRELLO_TOKEN"],
      trello_key: ENV["TRELLO_KEY"]
    }

    config.trello_source = {
      REGEX: /http[s]{0,1}:\/\/trello\.com\/b\/(?'board_id'[^\/]+)\/(?'board_name'[^\/]+)/,
      FUNCTION: :fetch_from_trello,
      KEY: config.trello_token[:trello_key],
      TOKEN: config.trello_token[:trello_token]
    }
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
      # config.i18n.default_locale = :de

      # Do not swallow errors in after_commit/after_rollback callbacks.
      config.active_record.raise_in_transactional_callbacks = true
    end
  end

end
