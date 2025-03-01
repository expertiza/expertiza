#!/bin/bash

# Update package list
apt-get update -qq

# Install required system packages
apt-get install -y \
    openjdk-11-jdk \
    curl \
    default-mysql-client \
    default-libmysqlclient-dev \
    build-essential \
    libssl-dev \
    xz-utils

# Install Node.js 14 manually
NODE_VERSION="14.21.0"  # Last supported version for older glibc
cd /tmp
curl -O https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz
tar -xJf node-v${NODE_VERSION}-linux-x64.tar.xz
rm node-v${NODE_VERSION}-linux-x64.tar.xz
mv node-v${NODE_VERSION}-linux-x64 /usr/local/lib/nodejs
ln -s /usr/local/lib/nodejs/bin/node /usr/local/bin/node
ln -s /usr/local/lib/nodejs/bin/npm /usr/local/bin/npm

# Install bower
npm install -g bower

# Install Ruby dependencies
gem install rspec