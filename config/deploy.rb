require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :application, "expertiza"
set :repository,  "git://github.com/expertiza/expertiza.git"
set :use_sudo, false

set :scm, :git
#set :git_enable_submodules, 1
set :branch do
  branch = Capistrano::CLI.ui.ask "Branch to deploy (make sure to push first) [#{default_branch}]: "
  branch = default_branch if branch.empty?
  branch
end

set :bundle_without,  [:development, :test]

set :deploy_to, "/local/rails/expertiza"
set :runner, "www-data"
set :user do
  puts "\033[32mYou need to log in. This is generally your Unity ID.\033[0m"
  user = Capistrano::CLI.ui.ask "Login: "
end

namespace :deploy do
  task :stop do; end
  task :start do; end

  desc "Restart the application."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink shared files into the current deploy directory."
  task :symlink_shared do
    run "ln -s #{shared_path}/pg_data #{release_path}"
    run "ln -sf #{shared_path}/database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:update_code", "deploy:symlink_shared"

desc "Load data into the local development database."
task :load_data, :roles => :db, :only => { :primary => true } do
  require 'yaml'
 
  database = YAML::load_file('config/database.yml')
  filename = "dump.#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.gz"
  command = "mysqldump -u #{database['production']['username']} --password=#{database['production']['password']} #{database['production']['database']} --add-drop-table | gzip > /tmp/#{filename}"
 
  on_rollback { delete "/tmp/#{filename}" }
  run command do |channel, stream, data|
    puts data
  end

  on_rollback { system " rm -f #{filename}" }
  get "/tmp/#{filename}", filename

  logger.info 'Dropping and recreating database'
  system 'rake db:drop && rake db:create'

  logger.info 'Importing production database into local development database'
  system "gunzip -c #{filename} | mysql -u #{database['development']['username']} --password=#{database['development']['password']} #{database['development']['database']} && rm -f #{filename}"
end

set :default_environment, 'JAVA_HOME' => "/etc/alternatives/java_sdk/"
# set :default_environment, 'JAVA_HOME' => "/usr/lib/jvm/java-6-openjdk/"
