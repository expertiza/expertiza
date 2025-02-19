Deployment in Expertiza
=======================

This document provides steps for implementing automated deployments on successful builds.

## Deployment Targets 🎯

| Expertiza Branch | Capistrano Environment | Target Server                                           | IP Address    | Deployment User | Deployment Directory |
|------------------|------------------------|---------------------------------------------------------|---------------|-----------------|----------------------|
| main             | production             | [Production Server](lin-res103.csc.ncsu.edu)            | 152.14.92.215 | expertiza       | `/var/www`           |
| main             | staging                | [Testing Server](https://vclvm177-58.vcl.ncsu.edu/)     | 152.7.177.58  | expertiza       | `/var/www`           |
| development      | development            | [Development Server](https://vclvm178-10.vcl.ncsu.edu/) | 152.7.178.10  | expertiza       | `/var/www`           |

## Configuring a new Target Server 🎯

**Follow the steps in the [expertiza server setup](https://github.com/expertiza/expertiza/blob/main/setup/SETUP.md) to set up a new deployment target server for automated deployments.**

## Deployment using Capistrano ⚙️
### Capfile
Capfile should be in the project root. Make sure the Capfile has `require 'capistrano/bower'` entry and that it does NOT have the `require 'capistrano/rails/migrations'` entry.

### Capistrano env files
Under the `config/deploy` dir are the various environment configuration files. For every env file, make sure that:
1. The target server domain name/IP address is correct in all the places.
2. The deployment user is correct and has password-less SSH and sudo access on the target server.
3. Set the Java env: `set :default_env, 'JAVA_HOME' => '/usr/jdk-11'`
4. Set the branch to be deployed in this environment: `set :branch, 'main'`
5. Set the correct Ruby version (and make sure this version is installed in the target RVM): `set :rvm_ruby_version, '2.4'`


## Deployment using GitHub Action ⏯️
GitHub Action is not a replacement for Capistrano. Actions just provides build validation. On a successful build, we can trigger action to deploy the build using Capistrano.

### Local machine
Follow the below steps to encrypt the secret private key and upload it in the repository. This private key would be used to ssh and deploy into the target server.

1. Generate SSH keys on the target machine if not already there
    ```bash
    ssh-keygen
    ```
2. Export the public key to the `authorized_keys` file to allow for remote login.
    ```bash
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    ```
3. Encrypt your private key with a strong password.
    ```bash
    openssl enc -aes-256-cbc -md sha512 -salt -in .ssh/id_rsa -out deploy_id_rsa_enc -k <PASSWORD> -a -pbkdf2
    ```
4. Add `deploy_id_rsa_enc` content as a secret in repository settings via *Settings / Secrets / Add* with name `ENCRYPTED_PRIVATE_KEY_PROD`

5. **Change** database password in `shared/config/database.yml` with `YOURNEWPASSWORD` which is default to `root`

6. Run `bundle exec rake secret`, <br>
   It will output a secret key, copy that and assign to production `secret_key_base` in `shared/config/secrets.yml`

7. Save the password used in step 4 as a secret in repository settings via *Settings / Secrets / Add* with name `DEPLOY_ENC_KEY`

   <img width="1125" alt="encrypted_secrets" src="https://user-images.githubusercontent.com/20452032/202915304-7ac97e52-fb2c-41af-8067-fca70f13a1f0.png">

8. Create YAML configuration for your workflow (example below)

    ```yaml
    name: Deploy with Capistrano
    on:
      workflow_dispatch:
    jobs:
      deploy:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v3
        - uses: ruby/setup-ruby@v1
          with:
            ruby-version: 2.4 
            bundler-cache: true # runs 'bundle install' and caches installed gems automatically
        - uses: miloserdow/capistrano-deploy@v2.2
          with:
            target: production # Defines the environment that will be used for the deployment
            enc_rsa_key_val: ${{ secrets.ENCRYPTED_PRIVATE_KEY_PROD }}
            deploy_key: ${{ secrets.DEPLOY_ENC_KEY }}    
    ```

9. Perform deployment run manually (optional):
   <img width="1440" alt="capistrano" src="https://user-images.githubusercontent.com/20452032/202915322-0dc0a001-2fcf-487c-a483-f5d293f31331.png">

## After application deployment

These are the **after steps** of deployment using capistrano. Follow these instruction after you have deployed the application to the server. You have to follow these steps **only once** and not after every deployment.

1. Migrate Old database (optional)
   ```bash
   # On old server
   mysqldump -u root -p expertiza_production > expertiza_production_dump.sql
   # On new server
   mysql -u root -p expertiza_production < expertiza_production_dump.sql
   ```

### Apache Configuration
Create two Apache configuration files and setup a virtual host entry that points to expertiza app. This virtual host entry tells Apache (and Passenger) where your app is located.

1. Create `expertiza_http.conf`
   ```bash
   sudo vi /etc/httpd/conf.d/expertiza_http.conf
   ```

   Put this inside the file:
   ```bash
   <VirtualHost *:80>
        ServerName <Server IP>

        # Tell Apache and Passenger where your app's 'public' directory is
        DocumentRoot /var/www/expertiza/current/public

        PassengerRuby /usr/local/rvm/gems/ruby-2.4.10/wrappers/ruby

        # Relax Apache security settings
        <Directory /var/www/expertiza/current/public>
          Allow from all
          Options -MultiViews
          Require all granted
        </Directory>
    </VirtualHost>
   ```
2. Create another apache config

   ```bash
    sudo vi /etc/httpd/conf.d/expertiza.conf
   ```

   Put this inside the file:
   ```bash
   <VirtualHost *:443>
        ServerName <Server IP>
        DocumentRoot /var/www/expertiza/current/public
        PassengerRuby /usr/local/rvm/gems/ruby-2.4.10/wrappers/ruby       

        <Directory /var/www/expertiza/current/public>
          Allow from all
          Options -MultiViews
          Require all granted
        </Directory>
    </VirtualHost>
   ```
3. While running locally, set `config.force_ssl = false` and `config.use_ssl = false` in `config/environments/production.rb`

4. Restart apache
   ```bash
   sudo systemctl restart httpd
   ```
5. Make curl request to test `curl <server IP>`

6. Expose `port 80` for exposing the application to network
    ```bash
    sudo firewall-cmd --zone=public --permanent --add-port=80/tcp
    sudo firewall-cmd --reload
    ```
7.  Go to `<Server IP>:80`


## Tips 💡
1. Add `Rake::Task["deploy:migrate"].clear_actions` to `deploy.rb` to disable the migrate rake tasks during deployment.
2. Run `bundle lock --update` to update the `Gemfile.lock` after any changes to the `Gemfile`. Make sure to track both files in git.
3. **Make sure redis server is always running on your server**
