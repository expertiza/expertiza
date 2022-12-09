Set up system to run Expertiza
=================================

This document provides steps for setting up new `RHEL/CENTOS` system/server to run expertiza.

## Create expertiza user (Optional)
1. Create expertiza user
    ```bash
    sudo useradd -m expertiza -p <password>
    ```
2. Add user to expertiza group
    ```bash
    sudo usermod -a -G expertiza expertiza
    ```
3. Allow `expertiza` user to be accessible from ssh

    - Append `expertiza` to AllowUsers in `/etc/ssh/external_sshd_config`
         ```bash
         AllowUsers xyz expertiza
         ``` 
    - Restart `ext_sshd` service
        ```bash
        sudo systemctl restart ext_sshd
        ```
4. Add `expertiza` user in sudoers file `/etc/sudoers`
    ```bash
    expertiza ALL= NOPASSWD: ALL
    ```
5. Switch to `expertiza` user for all the other instructions
    ```bash
    sudo su - expertiza
    ```

## Initialize Server
Follow these steps to allow remotely setting expertiza server using [ansible playbook](https://github.com/mundra-ankur/expertiza/blob/main/setup/setup_playbook.yml):

1. Enable Firewall Service and expose port tcp/22
    ```bash
    sudo systemctl mask ip6tables
    sudo systemctl mask iptables
    sudo systemctl mask ebtables
    sudo systemctl mask ipset

    sudo systemctl start firewalld
    sudo systemctl enable firewalld
    sudo firewall-cmd --zone=public --permanent --add-port=22/tcp
    sudo firewall-cmd --reload
    ```
2. After step1, make sure firewall is running and port is exposed
   ```bash
   sudo systemctl status firewalld
   sudo firewall-cmd --zone=public --permanent --list-ports
   ```
3. Generate SSH key pairs if not already created
    ```bash
    ssh-keygen
    ```
4. Export public key to the `authorized_keys` to allow the usage of this keypair to login
    ```bash
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    ```
5. Add private key from `~/.ssh/id_rsa` to your repository's secret keys with name <strong>`SSH_PRIVATE_KEY`</strong> - [Creating encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)

6. Add HOST and USER in your  repository's secret keys
   ```
   Name - SSH_HOST
   Secret - 152.7.99.76 <Your Server's IP>
   
   Name - SSH_USER
   Secret - expertiza <Your Server's user>
   ```

    <img width="1136" alt="Screenshot 2022-11-18 at 5 14 11 PM" src="https://user-images.githubusercontent.com/20452032/202812339-d7b3927d-8fd7-4094-afba-65b2063eed13.png">

7. Change `user` and `group` in ansible [playbook](https://github.com/mundra-ankur/expertiza/blob/main/setup/setup_playbook.yml) accordingly
    ```yml
    ---
    - name: Setup Expertiza System
      hosts: node
      become: true

      vars:
        user: expertiza
        group: expertiza
        user_home: "/home/{{ user }}"
        app_root: /var/www/expertiza
        ruby_version: 2.4
    ```

## Automated Set Up using Ansible Playbook
Go to Actions tab inside your repo -> choose Ansible System Setup -> Run workflow <br>

   <img width="1436" alt="action" src="https://user-images.githubusercontent.com/20452032/201730226-99131257-0287-4ab9-b625-abecabde9ef6.png">

## Manual Set Up
**Note:** These are not optional/alternative instructions
These are the steps that needs to be followed manually on the server

1. Set default ruby (Ruby version: 2.4)
   ```bash
   rvm alias create default 2.4 
   rvm use 2.4
   ```
2. Change Mysql database password
    ```bash
    mysql -u root mysql
    UPDATE mysql.user SET Password = PASSWORD('YOUR-NEW-PASSWORD') WHERE User = 'root'; FLUSH PRIVILEGES; exit;
    ```
3. **Change** database password in `config/database.yml` with `YOURNEWPASSWORD` which is default to `root`

4. Create expertiza databases, run `mysql -u root -p` then
    ```sql
    CREATE DATABASE expertiza_production;
    CREATE DATABASE expertiza_development;
    CREATE DATABASE expertiza_test;
    ```
6. Run `bundle install`

7. Load database schema and run migration, `Environment: {production, development, test}`
    ```bash
    RAILS_ENV=production bin/rake db:schema:load 
    RAILS_ENV=production bin/rake db:migrate
    ```
8. Start rails server, run `rails server`
