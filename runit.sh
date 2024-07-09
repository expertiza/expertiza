 #!/bin/bash

sudo kill -9 $(ps aux | grep 'redis-server' | grep -v grep | awk '{print $2}')
sudo kill -9 $(ps aux | grep 'expertiza' | grep -v grep | awk '{print $2}')
cd expertiza_SSO
bundle install
bower install
sudo systemctl start mariadb
sudo rake db:migrate
sudo redis-server &
sudo echo -ne '\n'
sudo iptables -I INPUT -p tcp -s 0.0.0.0/0 --dport 8080 -j ACCEPT
sudo ufw allow 8080
sudo ufw reload
rails s -p 8080 -b 152.7.177.3
