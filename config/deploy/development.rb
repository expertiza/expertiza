# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:
server '152.7.178.10', user: 'expertiza', roles: %w[web app]

set :default_env, 'JAVA_HOME' => '/usr/jdk-11'
set :branch, 'main'
set :rvm_ruby_version, '2.4'

# role-based syntax
role :app, %w[expertiza@152.7.178.10]
role :web, %w[expertiza@152.7.178.10]
role :db,  %w[expertiza@152.7.178.10]
