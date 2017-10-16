## Expertiza Installation using Docker

### Operating Systems: 

* Mac
* Linux

### Prerequisites:

* [Docker](https://www.docker.com/)
* [Docker-Compose](https://docs.docker.com/compose/install/)


### Installation steps: 

1. Mac:

  * Clone your forked Expertiza github repository 
  * Go to the `expertiza/docker` folder
  * Run the following command: `bash setup_mac.sh`

2. Linux: 

  * Clone your forked Expertiza github repository 
  * Go to the `expertiza/docker` folder
  * Run the following command: `bash setup_linux.sh`

#### After you run the script you need to do the following: 

* You will be required to fill in your MY SQL PASSWORD. Put any password for you MySQL Database.
* After some time open up your browser and go to the `localhost:3000` 
* If you see the following error, it means the script ran successfully and you just need to do the database migration.
![migration_error](https://github.com/VivekBhat/expertiza/blob/master/docker/migration_pending_error.png)
