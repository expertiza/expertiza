puts "*** \033[1;41mUsing a PROXY to connect to the server!\033[0m"
set :proxy_server do Capistrano::CLI.ui.ask "Proxy server: " end
set :port         do Capistrano::CLI.ui.ask "Port: " end
set :default_branch, 'staging'
role :web, proxy_server
role :app, proxy_server
role :cron, proxy_server
role :db,  proxy_server, :primary => true # This is where Rails migrations will run
