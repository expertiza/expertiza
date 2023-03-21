FROM ruby:2.3

COPY . /app
WORKDIR /app

RUN /bin/sh docker_setup.sh
RUN npm install -g bower
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
RUN bower install --allow-root
RUN bundle install
RUN bundle config set --local path 'vendor/cache'
ENTRYPOINT ["/app/docker_entrypoint.sh"]