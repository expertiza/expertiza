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
else
   echo
   echo "The file expertiza_scrubbed_db.sql.tar.gz not found."
   echo "Download the scrubbed database here, from: https://goo.gl/60RnWx"
   echo "EXITING..."
   echo
   exit 0
fi
# Untar it
tar -xzf expertiza_scrubbed_db.sql.tar.gz 

cd $DIR

# Get the docker-compose file
cp ./devops/docker/docker-compose.yml.example docker-compose.yml

# Get the MYSQL_ROOT_PASSWORD
read -p "Please enter your MYSQL ROOT PASSWORD: " MYSQL_ROOT_PASSWORD

# Update docker-compose with the MYSQL_ROOT_PASSWORD
sed -i -dummy "s/.*MYSQL_ROOT_PASSWORD.*/      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD/" docker-compose.yml

rm -rf docker-compose.yml-dummy

# Modify config/database.yml

cd $DIR/config

# Update database.yml with the MYSQL_ROOT_PASSWORD
sed -i -dummy "s/.*password.*/  password: $MYSQL_ROOT_PASSWORD/" database.yml
rm -rf database.yml-dummy

# Update the database.yml with the scrubbed_db
sed -i -dummy "s/.*host.*/  host: scrubbed_db/" database.yml
rm -rf database.yml-dummy

cd $DIR

# Close any docker containers if any
docker-compose down

# Finally docker-compose up in the background
docker-compose up  &
