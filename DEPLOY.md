# Deployment changes:

## Remote deployment server

1. Install `rvm`. Run `sudo ln -s /usr/share/rvm/ /usr/local/rvm` after successful rvm install.
2. Install ruby version `2.6.6` using the `rvm`
3. Install `mysql-server`
4. Install `mysql-devel`
5. Make sure user `root` has remote login enabled with no password on both `localhost` and `127.0.0.1`. Use the following commands:
```sql
create user 'root'@'127.0.0.1' identified by '';
grant all privileges on *.* to 'root'@'127.0.0.1' with grant option;
flush privileges;
```
6. Install `sudo yum install git -y`
7. Install Node.js with 
```bash
sudo yum install -y gcc-c++ make 
curl -sL https://rpm.nodesource.com/setup_16.x | sudo -E bash - 
sudo yum install nodejs -y
```
8. Install Java JDK 8 with `sudo yum install java-1.8.0-openjdk-devel -y`
9. Run following commands to set relevant Java environment variables:

```bash
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
```
10. Ensure the required files are available on the server `secrets.yml, database.yml, public1.pem, private2.pem` at `<project-root>/shared/config`

## `/.travis.yml`

1. Change rvm to 2.6.6
2. Add branch you want to deploy under `branches`.
3. Add following section:
```yml
after_success:
- openssl aes-256-cbc -k $DEPLOY_KEY -in config/deploy_id_rsa_enc_travis -d -a -out config/deploy_id_rsa
- chmod 400 config/deploy_id_rsa_enc_travis
- chmod 400 config/deploy_id_rsa
- ssh-add -k config/deploy_id_rsa
- bundle exec cap staging deploy --trace
```

2. Add the following lines at the end:
```ruby
gem 'ed25519', '1.2.4'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
```

## Capfile

Add `require 'capistrano/bower'` to Capfile to install all the npm dependencies defined in `/bower.json` during deployment.

## `/config/deploy.rb`

1. Change all occurrences of `production` to `staging`.
2. Edit line and set to `lock '~> 3.17.0'`
3. Edit line and set to `set :repo_url, 'https://github.com/<YOUR_GITHUB_USER>/expertiza.git'`
4. Edit line and set to `set :rvm_ruby_version, '2.6.6'`
5. Edit line and set to `set :deploy_to, "/home/<username>/expertiza_deploy"` E.g.:`/home/krshah3/expertiza_deploy"`
6. Edit line and set to `set :branch, 'deploy'`
7. Make sure `JAVA_HOME` under `set :default_env` is correctly set according to the value in the remote server.

**TIP:** Add `Rake::Task["deploy:migrate"].clear_actions` to `deploy.rb` to disable the migrate rake tasks during deployment. 

## `/config/deploy/staging.rb`

1. Edit and set line to `server '<YOUR_DEPLOYMENT_SERVER>', user: '<SERVER_USER>', roles: %w[web app db], my_property: :my_value`
2. Edit user name in following lines:
```ruby
role :app, %w[<SERVER_USER>@<YOUR_DEPLOYMENT_SERVER>]
role :web, %w[<SERVER_USER>@<YOUR_DEPLOYMENT_SERVER>]
role :db,  %w[<SERVER_USER>@<YOUR_DEPLOYMENT_SERVER>]
```

## Gemfile
1. Add `gem 'capistrano-bower'` to Gemfile, to install all the npm dependencies in the target server.
2. run `bundle lock --update` after above changes to generate a new Gemfile.lock.</br>
**ERROR:** `Could not find gem 'ruby (~> 2.3.1.0)' in the local ruby installation. The source contains 'ruby' at: 2.6.6.146` error. : Make sure you are on the right `deploy` branch.

## `/bower.json`
1. Add dependency `"tinymce": "latest"` in the bower.json file.

## Remote server

Run command to add Travis servers to firewall:

```bash
sudo iptables -I INPUT -p tcp -s "$(dig +short nat.travisci.net | tr -s '\r\n' ',' | sed -e 's/,$/\n/')" --dport 22 -j ACCEPT
```

## Local machine

Follow the bewlo steps to encrypt the secret private key and upload it in the repository. This private key would be used to ssh and deploy into the target server.
```bash
gem instal travis
travis login --pro --github-token <token>
travis encrypt DEPLOY_KEY="password for encryption" --add
openssl aes-256-cbc -k "password for encryption" -in ~/.ssh/id_rsa -out deploy_id_rsa_enc_travis -a
```

Check for further reference: https://gist.github.com/waynegraham/5c6ab006862123398d07 .
