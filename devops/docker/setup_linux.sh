#!/bin/bash

cd ../..

DIR=`pwd`

# Setup the environment
bash setup.sh

# Go back to docker folder
cd $DIR/devops/docker/scrubbed_db

# Checking the scrubbed_db

if [ -f expertiza_scrubbed_db.sql.tar.gz ]; then
   echo "The file expertiza_scrubbed_db.sql.tar.gz exists."
   tar -xzf expertiza_scrubbed_db.sql.tar.gz
elif [ -f expertiza_scrubbed_db_2019.09.17.rar ]; then
   echo "The file expertiza_scrubbed_db.sql.rar exists."
   unrar e -o+ expertiza_scrubbed_db_2019.09.17.rar .
   sed -i '1i CREATE DATABASE IF NOT EXISTS expertiza_development; USE expertiza_development;' expertiza_scrubbed_db_2019.09.17.sql
else
   echo
   echo "The file expertiza_scrubbed_db.sql.tar.gz not found."
   echo "Download the scrubbed database here, from: https://goo.gl/60RnWx"
   echo "EXITING..."
   echo
   exit 0
fi

cd $DIR

# Get the docker-compose file
cp ./devops/docker/docker-compose.yml.example docker-compose.yml
cp ./devops/docker/Dockerfile Dockerfile

# Get the MYSQL_ROOT_PASSWORD
read -p "Please enter your MYSQL ROOT PASSWORD: " MYSQL_ROOT_PASSWORD

# Update the password in docker-compose
sed -i "s/.*MYSQL_ROOT_PASSWORD.*/      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD/" docker-compose.yml

cd  $DIR/config

## Modify config/database.yml

# Update database.yml with the MYSQL_ROOT_PASSWORD
sed -i "s/.*password.*/  password: $MYSQL_ROOT_PASSWORD/" database.yml

# Update the database.yml with the scrubbed_db
sed -i "s/.*host.*/  host: scrubbed_db/" database.yml

cd $DIR

# Close any docker containers if any
sudo docker-compose down

# Finally docker-compose up in the background
sudo docker-compose up  &
