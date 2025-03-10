# CapistranoDbTasks (https://github.com/sgruhier/capistrano-db-tasks)
require 'capistrano-db-tasks'

# if you haven't already specified
set :rails_env, 'production'

# if you want to remove the local dump file after loading
set :db_local_clean, true

# if you want to remove the dump file from the server after downloading
set :db_remote_clean, true

# If you want to import assets, you can change default asset dir (default = system)
# This directory must be in your shared directory on the server
set :assets_dir, %w[public/assets public/att]
set :local_assets_dir, %w[public/assets public/att]

# if you want to work on a specific local environment (default = ENV['RAILS_ENV'] || 'development')
set :locals_rails_env, 'production'

# config valid for current version and patch releases of Capistrano
# lock '~> 3.10.1'

set :application, 'expertiza'
set :repo_url, 'https://github.com/expertiza/expertiza.git'
set :rvm_ruby_version, '2.4'
# Default branch is :main
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"
set :linked_files, %w[config/database.yml
                      config/secrets.yml
                      public.pem
                      private.pem]

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :linked_dirs, %w[log pg_data vendor/assets/components]

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env,
    'PASSENGER_INSTANCE_REGISTRY_DIR' => '/var/run/passenger-instreg',
    'JAVA_HOME' => '/usr/jdk-11'

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.username`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 10

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :passenger_in_gemfile, true
set :passenger_restart_with_touch, true

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
