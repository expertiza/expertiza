#!/bin/bash

# Remove any unnecessary data from the specified database then back it
# up.

# This script is designed to run interactively -- hence the `read`
# prompts.  Change these to env. declarations to make the script
# non-interactive.

# This script assumes that your DB password is specified in your
# ~/.my.cnf file.  If not, you would need to execute these commands
# from the console and add the "-p" option so mysql prompts for your
# password.


# Prompt for host, database etc.
read -p "Database hostname/IP: " DBHOST
read -p "Database catalog: " DBCATALOG
read -p "Database user: " DBUSER

# Remove contents of tables that don't need to be backed up.
#  - Sessions that have already expired:
mysql -h $DBHOST -u $DBUSER $DBCATALOG -e 'delete from sessions where curdate() > (date_add(updated_at, INTERVAL (select session_timeout from system_settings) SECOND))'

# Backup database:
mysqldump -h $DBHOST -u $DBUSER --no-create-db --skip-extended-insert --skip-comments $DBCATALOG | sed "{s/\/\*\!50013 DEFINER=.*//}" > db/goldberg_db_mysql.sql
