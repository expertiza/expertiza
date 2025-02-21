#!/bin/bash

# Update package list
apt-get update

# Install required system packages
apt-get install -y \
    curl \
    default-mysql-client \
    default-libmysqlclient-dev

# Install nvm (Node Version Manager)
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load nvm for the current shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js using nvm
nvm install 14  # Install Node.js 14
nvm use 14      # Use Node.js 14
nvm alias default 14  # Set Node.js 14 as the default version

# Install global npm packages
npm install -g bower

# Install Ruby dependencies
gem install rspec