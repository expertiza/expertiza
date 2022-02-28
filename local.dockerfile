FROM ruby:2.3.7

COPY . /app
WORKDIR /app

RUN /bin/sh docker_setup.sh
RUN npm install -g bower
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
RUN gem install rjb -v '1.4.9' --source 'https://rubygems.org/'
RUN bower install --allow-root
RUN bundle install
RUN bundle config set --local path 'vendor/cache'
ENTRYPOINT ["/app/docker_entrypoint.sh"]