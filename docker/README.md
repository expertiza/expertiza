## Expertiza Installation using Docker

### Operating Systems: 

* Mac
* Linux

### Prerequisites:

* [Docker](https://www.docker.com/)
* [Docker-Compose](https://docs.docker.com/compose/install/)
* Make sure that you place the **'scrubbed_db'** in the scrubbed_db folder.
   * Download the scrubbed database from: https://goo.gl/60RnWx


### Installation steps: 

1. Mac:

  * Clone your forked Expertiza github repository: `git clone YOUR_REPO_LINK.git` 
  * Go to the expertiza/docker folder: `cd expertiza/docker`
  * Run the `setup_mac.sh` script : `bash setup_mac.sh`

2. Linux: 

  * Clone your forked Expertiza github repository: `git clone YOUR_REPO_LINK.git` 
  * Go to the expertiza/docker folder: `cd expertiza/docker`
  * Run the `setup_linux.sh` script: `bash setup_linux.sh`

#### After you run the script you need to do the following: 

* You will be required to fill in your MY SQL PASSWORD. Put any password for you MySQL Database.
* After some time open up your browser and go to the `localhost:3000` 
* If you see the following error, it means the script ran successfully and you just need to do the database migration.
![migration_error](https://i.stack.imgur.com/Om4yH.png)

#### Database Migration

* Once you see the above error, open up a new terminal.
* List all the active containers by typing `sudo docker ps -a`
* Look for the CONTAINER ID of the IMAGE `winbobob/expertiza:ruby-2.2.7`
* And run the following command: `sudo docker exec -it <CONTAINER ID> bin/rake db:migrate RAILS_ENV=development`
* For example: 

   ```
   vivekbhat$ sudo docker ps -a 
   CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS                        PORTS                    NAMES
   2a63f480521f        winbobob/expertiza:ruby-2.2.7   "bundle exec thin ..."   12 hours ago        Exited (255) 3 hours ago      0.0.0.0:3000->3000/tcp   expertiza_expertiza_1
   017b6688d44c        redis:alpine                    "docker-entrypoint..."   12 hours ago        Exited (255) 3 hours ago      6379/tcp                 expertiza_redis_1
   7c9e5c30de7c        mysql:5.7                       "docker-entrypoint..."   12 hours ago        Exited (255) 3 hours ago      3306/tcp                 expertiza_scrubbed_db_1

   vivekbhat$ sudo docker exec -it 2a63f480521f bin/rake db:migrate RAILS_ENV=development
   ```
* Wait for the program to finish the database migration
* Once completed go to `localhost:3000` and Expertiza should be up and running :) 

