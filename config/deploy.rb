#Use `cap my_stage TASK` such as `cap production deploy`
set :stages, %w(production staging)
set :default_stage, "staging"

require 'capistrano/ext/multistage'

set :application, "expertiza"
set :repository,  "git://github.com/expertiza/expertiza.git"
set :user, "rails"
set :group, "rails"
set :use_sudo, false
set :runner, "www-data"

set :bundle_without,  [:development, :test]
set :deploy_via, :remote_cache

role :web, "expertiza.csc.ncsu.edu"
role :app, "expertiza.csc.ncsu.edu"
role :cron, "expertiza.csc.ncsu.edu"
role :db,  "expertiza.csc.ncsu.edu", :primary => true # This is where Rails migrations will run