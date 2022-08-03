apt-get update
curl -sL https://deb.nodesource.com/setup_14.x | sh -
apt-get install -y nodejs
apt-get install -y npm
apt-get install -y default-mysql-client
npm install -g bower
apt-get install -y openjdk-8-jdk
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
# gem install rjb -v '1.6.4' --source 'https://rubygems.org/'
apt-get install default-libmysqlclient-dev
gem install rspec