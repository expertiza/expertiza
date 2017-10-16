#!/bin/bash

# Create a directory named scrubbed_db to store the scrubbed_db
mkdir -p scrubbed_db

cd ..

DIR=`pwd`

# Setup the environment
bash setup.sh

# Go back to docker folder
cd $DIR/docker/scrubbed_db

# Downloading the scrubbed_db
wget -nc {LINK}

# Untar it
tar -xzf expertiza_scrubbed_db.sql.tar.gz 

cd $DIR

# Get the docker-compose file
cp docker-compose.yml.example docker-compose.yml

# Get the MYSQL_ROOT_PASSWORD
read -p "Please enter your MYSQL ROOT PASSWORD: " MYSQL_ROOT_PASSWORD

# Update the password in docker-compose
sed -i "s/.*MYSQL_ROOT_PASSWORD.*/      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD/" docker-compose.yml

cd  $DIR/config


# Modify config/database.yml

# Update database.yml with the MYSQL_ROOT_PASSWORD
sed -i "s/.*password.*/  password: $MYSQL_ROOT_PASSWORD/" database.yml

# Update the database.yml with the scrubbed_db
sed -i "s/.*host.*/  host: scrubbed_db/" database.yml

cd $DIR

# Close any docker containers if any
sudo docker-compose down

# Finally docker-compose up in the background
sudo docker-compose up  &
