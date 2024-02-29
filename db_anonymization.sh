#!/bin/bash

abs_path='/path/to/expertiza/on/server'

cd $abs_path

gem install bundler -v 1.16.6
gem install pkg-config -v "~> 1.1"

bundle config build.nokogiri --use-system-libraries > /dev/null 2>&1
bundle 1.16.6 install > /dev/null 2>&1
bundle -v

script_source="$abs_path/lib/tasks/scrub_database.rake"
timestamp=$(date +%Y-%m-%d_%H-%M)

mkdir -p ./anonymized_dumps
mkdir -p ./production_dumps

# Create a database dump
production_db_source="/production_dumps/prod_$timestamp.sql"
mysqldump -uroot -pexpertiza expertiza_development > "$production_db_source"

# echo "Create a expertiza_production_dumps database"
db_name="expertiza_production_dumps"
mysql -uroot -pexpertiza -e "CREATE DATABASE IF NOT EXISTS $db_name"

# echo "Importing production db into expertiza_production_dumps"
mysql -uroot -pexpertiza $db_name < $production_db_source > /dev/null # ~/cron.log

# echo "Running anonymization task"
rake db:data:scrub  > /dev/null # ~/cron.log
# rake db:data:scrub --trace

# echo "Creating a dump file of the scrubbed db"
mysqldump -u root -pexpertiza expertiza_development --ignore-table=expertiza_development.sessions > "$abs_path/anonymized_dumps/dump_$timestamp.sql"