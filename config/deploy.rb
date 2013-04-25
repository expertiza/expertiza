require 'bundler/capistrano'

task :alldos2unix do
  `find ./*`.split("\n").each do |str|
    `dos2unix #{str}`
  end
end

set :application, "expertiza"
set :repository,  "git://github.com/expertiza/expertiza.git"
set :use_sudo, false

set :scm, :git
#set :git_enable_submodules, 1

set :bundle_without,  [:development, :test]

set :deploy_to, "/local/rails/expertiza"
set :runner, "www-data"

desc "Run tasks from a proxied environment"
task :proxy do
  puts "*** \033[1;41mUsing a PROXY to connect to the server!\033[0m"
  
  set :proxy_server do
    proxy_server = Capistrano::CLI.ui.ask "Server: "
  end
  
  role :web, proxy_server
  role :app, proxy_server
  role :cron, proxy_server
  role :db,  proxy_server, :primary => true # This is where Rails migrations will run
  
  set :port do
    port = Capistrano::CLI.ui.ask "Port: "
  end
  
  set :user do
    puts "\033[32mYou need to log in. This is generally your Unity ID.\033[0m"
    user = Capistrano::CLI.ui.ask "Login: "
  end
  
  set :branch do
    default_branch = 'staging'
    
    branch = Capistrano::CLI.ui.ask "Branch to deploy (make sure to push first) [#{default_branch}]: "
    branch = default_branch if branch.empty?
    branch
  end
end

desc "Run tasks in staging enviroment."
task :staging do
  puts "*** Using the \033[1;42m STAGING \033[0m server!"
  role :web, "test.expertiza.csc.ncsu.edu"
  role :app, "test.expertiza.csc.ncsu.edu"
  role :cron, "test.expertiza.csc.ncsu.edu"
  role :db,  "test.expertiza.csc.ncsu.edu", :primary => true # This is where Rails migrations will run
  
  set :user do
    puts "\033[32mYou need to log in. This is generally your Unity ID.\033[0m"
    user = Capistrano::CLI.ui.ask "Login: "
  end
  
  set :branch do
    default_branch = 'staging'
    
    branch = Capistrano::CLI.ui.ask "Branch to deploy (make sure to push first) [#{default_branch}]: "
    branch = default_branch if branch.empty?
    branch
  end
end

desc "Run tasks in production enviroment."
task :production do
  puts "*** Using the \033[1;41m PRODUCTION \033[0m server!"
  role :web, "expertiza.ncsu.edu"
  role :app, "expertiza.ncsu.edu"
  role :cron, "expertiza.ncsu.edu"
  role :db,  "expertiza.ncsu.edu", :primary => true # This is where Rails migrations will run
  
  set :user do
    puts "\033[32mYou need to log in. This is generally your Unity ID.\033[0m"
    user = Capistrano::CLI.ui.ask "Login: "
  end
  
  set :branch do
    default_branch = 'production'
    
    branch = Capistrano::CLI.ui.ask "Branch to deploy (make sure to push first) [#{default_branch}]: "
    branch = default_branch if branch.empty?
    branch
  end
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
