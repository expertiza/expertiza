FROM ruby:2.4.10

COPY . /app
WORKDIR /app

# Run the setup script
RUN /bin/sh docker_setup.sh

# Set JAVA_HOME to match the actual Java installation path
ENV JAVA_HOME="/usr/lib/jvm/java-8-oracle"
ENV NVM_DIR="/root/.nvm"

# Load nvm and install bower
RUN . "$NVM_DIR/nvm.sh" && npm install -g bower

# Install bundler and project dependencies
RUN bundle install
RUN bundle config set --local path 'vendor/cache'

ENTRYPOINT ["/app/docker_entrypoint.sh"]