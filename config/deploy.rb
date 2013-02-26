require 'bundler/capistrano'

set :application, "expertiza"
set :repository,  "git://github.com/expertiza/expertiza.git"
set :user, "rails"
set :use_sudo, false

set :scm, :git
#set :git_enable_submodules, 1

set :bundle_without,  [:development, :test]

set :deploy_to, "/local/rails/expertiza"
set :runner, "www-data"
set :branch do
  if ENV['DEPLOY'] == 'STAGING'
    default_branch = 'staging'
  else
    default_branch = 'production'
  end
  
  branch = Capistrano::CLI.ui.ask "Branch to deploy (make sure to push first) [#{default_branch}]: "
  branch = default_branch if branch.empty?
  branch
end

if ENV['DEPLOY'] == 'STAGING'
  puts "*** Deploying to the \033[1;42m  STAGING  \033[0m server!"
  role :web, "test.expertiza.csc.ncsu.edu"
  role :app, "test.expertiza.csc.ncsu.edu"
  role :cron, "test.expertiza.csc.ncsu.edu"
  role :db,  "test.expertiza.csc.ncsu.edu", :primary => true # This is where Rails migrations will run
else #production
  puts "*** Deploying to the \033[1;41m  PRODUCTION  \033[0m servers!"
  role :web, "expertiza.ncsu.edu"
  role :app, "expertiza.ncsu.edu"
  role :cron, "expertiza.ncsu.edu"
  role :db,  "expertiza.ncsu.edu", :primary => true # This is where Rails migrations will run
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

desc "Load production data into the local development database."
task :load_production_data, :roles => :db, :only => { :primary => true } do
  require 'yaml'
 
  database = YAML::load_file('config/database.yml')
  filename = "dump.#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.gz"
 
  on_rollback { delete "/tmp/#{filename}" }
  run "mysqldump -u #{database['production']['username']} --password=#{database['production']['password']} #{database['production']['database']} --add-drop-table | gzip > /tmp/#{filename}" do |channel, stream, data|
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
