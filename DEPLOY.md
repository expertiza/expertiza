# Deployment changes:

## Remote deployment server

1. Install `rvm`
2. Install ruby version `2.6.6` using the `rvm`
3. Install `mysql-server`
4. Install `mysql-devel`
5. Install Node.js with `dnf module install nodejs:16`
6. Install Java JDK 8 with `sudo dnf install java-1.8.0-openjdk-devel`
7. Run following commands to set relevant Java environment variables:

```bash
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
```

## `/.travis.yml`

1. Change rvm to 2.6.6
2. Add branch you want to deploy under `branches`.
3. Add following section:
```yml
after_success:
- openssl aes-256-cbc -k $DEPLOY_KEY -in config/deploy_id_rsa_enc_travis -d -a -out config/deploy_id_rsa
- chmod 400 config/deploy_id_rsa_enc_travis
- chmod 400 config/deploy_id_rsa
- bundle exec cap staging deploy --trace
```

## `/Gemfile`

1. Edit the following lines:
```ruby
ruby '2.6.6'
gem 'rails', '= 5.1.0.rc2'
...
gem 'actionpack', '5.1.0.rc2'
gem 'activerecord', '5.1.0.rc2'
...
gem 'activesupport', '5.1.0.rc2'
...
gem 'railties', '5.1.0.rc2'
```

2. Add the following lines at the end:
```ruby
gem 'ed25519', '1.2.4'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
```

3. run `bundle lock --update` after above changes to generate a new Gemfile.lock.</br>
**ERROR:** `Could not find gem 'ruby (~> 2.3.1.0)' in the local ruby installation. The source contains 'ruby' at: 2.6.6.146` error. : Make sure you are on the right `deploy` branch.

## Capfile

Add `require 'capistrano/bower'` to Capfile to install all the npm dependencies during deployment.

## `/config/deploy.rb`

1. Change all occurrences of `production` to `staging`.
2. Edit line and set to `lock '~> 3.17.0'`
3. Edit line and set to `set :repo_url, 'https://github.com/<YOUR_GITHUB_USER>/expertiza.git'`
4. Edit line and set to `set :rvm_ruby_version, '2.6.6'`
5. Edit line and set to `set :deploy_to, "/home/krshah3/expertiza_deploy"`
6. Edit line and set to `set :branch, 'deploy'`
7. Make sure `JAVA_HOME` under `set :default_env` is correctly set according to the value in the remote server.

## `/config/deploy/staging.rb`

1. Edit and set line to `server '<YOUR_DEPLOYMENT_SERVER>', user: '<SERVER_USER>', roles: %w[web app db], my_property: :my_value`
2. Edit user name in following lines:
```ruby
role :app, %w[<SERVER_USER>@<YOUR_DEPLOYMENT_SERVER>]
role :web, %w[<SERVER_USER>@<YOUR_DEPLOYMENT_SERVER>]
role :db,  %w[<SERVER_USER>@<YOUR_DEPLOYMENT_SERVER>]
```

## Remote server

Run command to add Travis servers to firewall:

```bash
sudo iptables -I INPUT -p tcp -s "$(dig +short nat.travisci.net | tr -s '\r\n' ',' | sed -e 's/,$/\n/')" --dport 22 -j ACCEPT
```

## Local machine

Follow the steps given here: https://gist.github.com/waynegraham/5c6ab006862123398d07 to setup Travis password encryption keys.
