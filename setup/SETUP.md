Set up system to run Expertiza
=================================

**Target Audience:** Expertiza developers who are setting up a new `RHEL/CENTOS` server to run Expertiza on. A basic understanding of the Linux command line interface is required for debugging purposes. <br>

**You currently have**: A fresh `RHEL/CENTOS` system/server, referred to as the **Target server**. <br>

**You will end with**: A fully configured development environment for Expertiza on the Target server. <br>

**Purpose of the Guide**: The purpose of the guide is to take the user from a fresh system to a complete development environment for Expertiza. The environment can be used to run the `Rails server` and for subsequent deployment using Capistrano with [this](https://github.com/expertiza/expertiza/blob/main/setup/DEPLOY.md) guide.

## STEP 1:  Create an Expertiza User on the Target Server (Optional but Highly Recommended)
**Where** : This action is performed on your Target Server.<br>

To begin, you should create an Expertiza user on your Target Server. This user will have elevated root privileges, which will allow you to perform system-level tasks with ease. Follow the steps below to create an Expertiza user and give them the necessary permissions:

1. Create expertiza user
    ```bash
    sudo useradd -m expertiza -p <password>
    ```
2. Add user to expertiza group
    ```bash
    sudo usermod -a -G expertiza expertiza
    ```
3. Allow `expertiza` user to be accessible from ssh. You can learn more about [configuring ssh](https://man7.org/linux/man-pages/man5/sshd_config.5.html).

    - Append `expertiza` to AllowUsers in `/etc/ssh/external_sshd_config`
         ```bash
         AllowUsers xyz expertiza
         ``` 
    - Restart `ext_sshd` service
        ```bash
        sudo systemctl restart ext_sshd
        ```
4. Add `expertiza` user in sudoer file `/etc/sudoers`. This will help give expertiza user elevated root privilege. You can learn more about [Privilege separation and _super-user_ privileges here.](https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file)
    ```bash
    expertiza ALL= NOPASSWD: ALL
    ```
5.  Switch to `expertiza` user for **STEP 2**
    ```bash
    sudo su - expertiza
    ```

## STEP 2 : Initialize Target Server.
**Where** : This action is performed on your Target Server.<br>

Next, you need to initialize the Target Server to allow for remote access via [GitHub Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions). Follow these steps to set up the necessary firewall rules and SSH keys:

1. Enable the Firewall Service and expose TCP port 22 to allow for remote access:
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
2. Check that the firewall is running and that **TCP port 22** is exposed:
   ```bash
   sudo systemctl status firewalld
   sudo firewall-cmd --zone=public --permanent --list-ports
   ```
3. Generate an SSH key pair if you haven't already. You can learn more about [ssh-keygen here](https://www.ssh.com/academy/ssh/keygen).
    ```bash
    ssh-keygen
    ```
4. Export the public key to the `authorized_keys` file to allow for remote login.
    ```bash
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    ```
5. Add private key from `~/.ssh/id_rsa` to your repository's secret keys with name <strong>`SSH_PRIVATE_KEY`</strong> - [Creating encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)

6. Add the Target Server's IP address and expertiza user created in STEP 1 as secrets to your repository as SSH_HOST and SSH_USER, respectively.
   ```
   Name - SSH_HOST
   Secret - 152.7.99.76 <Your Server's IP>
   
   Name - SSH_USER
   Secret - expertiza <Your Server's user>
   ```

    <img width="1136" alt="Screenshot 2022-11-18 at 5 14 11 PM" src="https://user-images.githubusercontent.com/20452032/202812339-d7b3927d-8fd7-4094-afba-65b2063eed13.png">

7. Modify the `user` and `group` variables in the ansible [playbook](https://github.com/expertiza/expertiza/blob/main/setup/setup_playbook.yml) to match your Expertiza user and group.
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

## Step 4 : Setting Up the Target server Using Ansible Playbook Github Action.
**Where** : This action is performed on your Github Repository.<br>

To complete this step, you will need to run the [remote-system-setup.yml](https://github.com/expertiza/expertiza/blob/main/.github/workflows/remote-system-setup.yml) GitHub Action. To do so, navigate to the Actions tab in your repository and choose the Ansible System Setup workflow. Once the workflow is running, the Target Server will be set up according to the specifications in this [playbook](https://github.com/expertiza/expertiza/blob/main/setup/setup_playbook.yml) <br>

   <img width="1436" alt="action" src="https://user-images.githubusercontent.com/20452032/201730226-99131257-0287-4ab9-b625-abecabde9ef6.png"> <br>

## Step 5: Target Server Configuration
**Note:** These are the manual steps that must be performed on the target server in order to complete the set up and configure the application. These steps should be followed exactly as written and are not optional.

1. Set default `Ruby version to 2.4` using RVM (Ruby Version Manager)
   ```bash
   rvm alias create default 2.4 
   rvm use 2.4
   ```
2. Change the MySQL database password
    ```bash
    mysql -u root mysql
    UPDATE mysql.user SET Password = PASSWORD('YOUR-NEW-PASSWORD') WHERE User = 'root'; FLUSH PRIVILEGES; exit;
    ```
3. **Change** the database password in `config/database.yml` with `YOURNEWPASSWORD`  (which is currently set to `root` by default).

4. Create the required databases by running the following commands, run `mysql -u root -p` then
    ```sql
    CREATE DATABASE expertiza_production;
    CREATE DATABASE expertiza_development;
    CREATE DATABASE expertiza_test;
    ```
5. Run `bundle install` to install all the required dependencies.

6. Load the database schema and run the migrations. Choose the appropriate environment (`production`, `development`, or `test`) when running the commands:
    ```bash
    RAILS_ENV=production bin/rake db:schema:load 
    RAILS_ENV=production bin/rake db:migrate
    ```
    Replace `production` with `development` or `test` as needed for the respective environments.

7. Start rails server, run `rails server`


# Video Demonstration

https://user-images.githubusercontent.com/20452032/219795863-99c048ec-045f-4737-aab1-e29a704b9469.mp4


