FROM ruby:2.4.10

# Set working directory
WORKDIR /app

# Install system dependencies
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update -qq && \
    apt-get install -y \
      openjdk-11-jdk \
      curl \
      default-mysql-client \
      default-libmysqlclient-dev \
      build-essential \
      libssl-dev \
      xz-utils \
      nodejs npm

# Set JAVA_HOME for rjb
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
ENV PATH="$JAVA_HOME/bin:$PATH:/usr/local/lib/nodejs/bin"

# Install Node 14 manually (last supported for older glibc)
RUN NODE_VERSION="14.21.0" && \
    cd /tmp && \
    curl -O https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz && \
    tar -xJf node-v${NODE_VERSION}-linux-x64.tar.xz && \
    rm node-v${NODE_VERSION}-linux-x64.tar.xz && \
    mv node-v${NODE_VERSION}-linux-x64 /usr/local/lib/nodejs && \
    ln -s /usr/local/lib/nodejs/bin/node /usr/local/bin/node && \
    ln -s /usr/local/lib/nodejs/bin/npm /usr/local/bin/npm

# Set user and group
# RUN chown -R $USER:$GROUP ~/.npm
# RUN chown -R $USER:$GROUP ~/.config

# Install Bower globally
RUN npm install -g bower

# Install Ruby build dependencies and gems
RUN gem install bundler -v 1.16.6 \
    && gem install rspec

# Copy app code
COPY . /app

# Fix rjb build
RUN bundle config build.rjb --with-java-dir=$JAVA_HOME

# Install gems
RUN bundle install

# Install bower packages
RUN bower install --allow-root

# Set entrypoint
ENTRYPOINT ["/app/docker_entrypoint.sh"]