FROM ubuntu:16.04

# Prepare to install Java for 'rjb' gem
RUN apt-get update && apt-get -y install software-properties-common && add-apt-repository ppa:webupd8team/java -y && apt-get update 

# Install Java 8 and accept the license by default (https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04)
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && apt-get -y install oracle-java8-installer && java -version 

# Set JAVA_HOME (should add in the docker startup script)
RUN echo 'export JAVA_HOME="/usr/lib/jvm/java-8-oracle"' >> /etc/environment && . /etc/environment && echo $JAVA_HOME 

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install curl, rvm, ruby 2.1.5p273, rails 4.2.6
RUN apt-get -y update && apt-get -y install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev && apt-get -y install wget && apt-get install -y ruby-full && ruby -v && gem install rails -v 4.2.6 && rails -v

# Install bundler, git
RUN gem install bundler && apt-get -y install git

ENV DEBIAN_FRONTEND noninteractive   

# Make sure 'bundle install' run successfully and set the git pre-commit hooks
RUN ["/bin/bash", "-c", "cd home && mkdir expertiza_developer && cd expertiza_developer && git clone https://github.com/expertiza/expertiza.git && cd expertiza && apt-get -y install ruby-dev && apt-get -y install make && apt-get install -y gcc make && apt-get install -y libmysqlclient-dev && apt-get install -y libpq-dev && bundle install && debconf-set-selections <<< 'mysql-server mysql-server/root_password password ' && debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password ' && apt-get -y install mysql-server && /etc/init.d/mysql start && cp config/database.yml.example config/database.yml && cp config/secrets.yml.example config/secrets.yml && mv ./hooks/pre-commit ./.git/hooks/pre-commit && chmod 755 ./.git/hooks/pre-commit"]