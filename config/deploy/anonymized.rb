# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

server '152.7.179.77', user: 'expertiza', roles: %w[web app]

set :default_env, 'JAVA_HOME' => '/usr/jdk-11'
set :branch, 'anonymized_server'
set :rvm_ruby_version, '2.4'
# set :rails_env, 'anonymized'

# role-based syntax
role :app, %w[expertiza@152.7.179.77]
role :web, %w[expertiza@152.7.179.77]
role :db,  %w[expertiza@152.7.179.77]
