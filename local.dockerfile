FROM ruby:2.4.10

COPY . /app
WORKDIR /app

RUN bash docker_setup.sh

# Install bower
RUN npm install -g bower

ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
ENV PATH="/usr/local/lib/nodejs/bin:${PATH}"

RUN bower install --allow-root

RUN bundle install
RUN bundle config set --local path 'vendor/cache'

ENTRYPOINT ["/app/docker_entrypoint.sh"]