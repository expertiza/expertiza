puts "*** Using the \033[1;41m PRODUCTION \033[0m server!"
set :host, "expertiza.ncsu.edu"
set :default_branch, 'production'
role :web, host
role :app, host
role :cron, host
role :db, host, :primary => true
