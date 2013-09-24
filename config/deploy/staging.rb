puts "*** Using the \033[1;42m STAGING \033[0m server!"
set :host, "test.expertiza.csc.ncsu.edu"
set :default_branch, 'staging'
role :web, host
role :app, host
role :cron, host
role :db, host, :primary => true
