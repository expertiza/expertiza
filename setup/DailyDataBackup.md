Daily data backup
=================================

**Purpose of the Guide**: The purpose of the guide is to automate the process of taking daily backup from production server and storing it in test server and development server.

## STEP 1:  Generate/Get keys for the server
**Where** : This action is performed on your Source and Target Server.<br>

To begin, you should log in to an Expertiza user on your Source/Target Server. This user will have elevated root privileges, which will allow you to generate the keys stored on the server. Follow the steps below to login an Expertiza user and generate the keys:

1. Login to server
    ```bash
    ssh -X usern@host
    ```
2. Change user to expertiza
    ```bash
    sudo su - expertiza
    ```
3. list names and features of files and directories
    ```bash
    ls -la
    ```
4. Locate the key for the server in the ssh file
    ```bash
    cat .ssh/id_rsa
    ```
5.  Copy the key and create a create a secret for the key

## STEP 2 : How to create a secret
**Where** : This action is performed on your [GitHub repository](https://github.com/shubhangij12/test-expertiza/settings/secrets/actions).<br>

Next, you need to initialize the Target Server to  allow for remote access via [GitHub Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions). Follow these steps to set up the necessary firewall rules and SSH keys:

1. Go to Settings and go to Actions under Secrets and variables tab 
2. Click on "New Repository Secret" 
3. Paste the key in the Secret box and name the secret.


## Step 3 : Setting Up the backup time.
**Where** : This action is performed on your daily_data_transfer.yml file.<br>

1. Set time on the cron job. Currently, it is set to run at midnight.
   ```bash
   on:
    set up cron job to run at 12 AM everyday
    workflow_dispatch:
    schedule:
     - cron: '0 0 * * *' 
   ```
--------------------------------------------------------------------------------------------------------------------------------------------
## How to manually run this workflow file while testing

Go to **Actions tab** -> **Automatic data transfer** -> **Run workflow**
