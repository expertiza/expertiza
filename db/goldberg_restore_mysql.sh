#!/bin/bash

# Create a new, empty database and restore the backup of the Goldberg
# database into it.

# This script assumes that your DB password is specified in your
# ~/.my.cnf file.  If not, you would need to execute these commands
# from the console and add the "-p" option so mysql prompts for your
# password.


# Prompt for host, database etc.
read -p "Database hostname/IP: " DBHOST
read -p "Database catalog: " DBCATALOG
read -p "Database user: " DBUSER

# Create empty database
mysql -h $DBHOST -u $DBUSER -e "create database $DBCATALOG;"

# Restore from backup file
mysql -h $DBHOST -u $DBUSER $DBCATALOG < db/goldberg_db_mysql.sql
