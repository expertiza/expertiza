set :application, "expertiza"
set :repository,  "git://github.com/expertiza/expertiza.git"
set :user, "rails"

set :scm, :git
#set :git_enable_submodules, 1

set :deploy_to, "/local/rails/expertiza"
set :runner, "www-data"
set :branch, "master"

role :web, "expertiza.ncsu.edu"
role :app, "expertiza.ncsu.edu"
role :db,  "expertiza.ncsu.edu", :primary => true # This is where Rails migrations will run

namespace :deploy do
  desc "Stop Application (do nothing)"
  task :stop do; end

  desc "Start Application (do nothing)"
  task :start do; end

  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink shared static files"
  task :symlink_static do
    run "ln -s #{shared_path}/pg_data #{current_path}"
    run "ln -sf #{shared_path}/database.yml #{current_path}/config/database.yml"
  end
end

after "deploy:symlink", "deploy:symlink_static"
