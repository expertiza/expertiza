# Deployment changes:

## Remote deployment server

1. Install `rvm`
2. Install ruby version `2.6.6` using the `rvm`
3. Install `mysql-server` and `mysql-devel`
4. install `git` (`sudo yum install git`)
5. Ensure the required files are available on the server `secrets.yml, database.yml, public1.pem, private2.pem`

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

3. run `bundle lock --update` after above changes to generate a new Gemfile.lock.

## `/config/deploy.rb`

1. Change all occurrences of `production` to `staging`.
2. Edit line and set to `lock '~> 3.17.0'`
3. Edit line and set to `set :repo_url, 'https://github.com/<YOUR_GITHUB_USER>/expertiza.git'`
4. Edit line and set to `set :rvm_ruby_version, '2.6.6'`
5. Edit line and set to `set :deploy_to, <deploy path>"` E.g.:`/home/krshah3/expertiza_deploy"`

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
