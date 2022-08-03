#!/bin/sh
if [ ! -f .initialized ]; then                                                                                                                                                                                    
    echo "Initializing container"

    cp /app/config/secrets.yml.example /app/config/secrets.yml

    # Remove default development configuration
    sed '7,9d' ./config/database.yml.example  > ./config/database.yml

    echo "development:
  adapter: mysql2
  host: mysql
  username: root
  password: expertiza
  database: expertiza_production" >> ./config/database.yml

    # Begin to mount
    echo "Inserting scrubbed db into database... this may take awhile!"
    mysql --user=root --password=expertiza --host=mysql expertiza_production < /app/expertiza.sql

    if [ $? -ne 0 ]; then
        echo "Failed to import db"
        rm -rf /app/expertiza-db
        exit 1
    fi

    # run initializing commands      
    eval 'bundle exec rake db:migrate RAILS_ENV=development'
    if [ $? -eq 0 ]; then
        touch .initialized
        echo "Migrations success!"
    else
        echo "Failed migrations"
        rm -rf /app/expertiza-db
        exit 1
    fi                                                                                                                                                                           
                                                                                                                                                                                           
fi

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

echo "bundle exec rails s -b 0.0.0.0" > /app/docker-start.sh
chmod +x /app/docker-start.sh

echo "Expertiza container started"
/bin/sh -c "while sleep 1000; do :; done"