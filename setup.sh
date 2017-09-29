#!/bin/bash

###############
### For Mac ###
###############

if [ "$(uname)" == "Darwin" ]
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml

NODE_VERSION=8.4.0
NPM_VERSION=5.4.2

then
  echo 'Install Third-party Javascript Libraries for Mac OS X platform'
 
 # Checking Homebrew
  which -s brew
  if [[ $? != 0 ]] ; then
      # Install Homebrew
      /usr/bin/ruby -e "$(curl -fsSL https://raw.github.com/gist/323731)"
      echo "Brew was not installed"
  else
      echo "Brew already there"
      brew update
  fi

  # Checking Git
  echo "Checking for Git"
  which -s git || brew install git

  # Checking Node
  echo "Checking for Node"
  node --version
  if [[ $? != 0 ]] ; then
      # Install Node
      cd `brew --prefix`
      $(brew versions node | grep ${NODE_VERSION} | cut -c 16- -)
      brew install node

      # Reset Homebrew formulae versions
      git reset HEAD `brew --repository` && git checkout -- `brew --repository`
  else
    echo "NodeJS $(node -v) is already installed"
  fi

  # Checking NPM
  echo "Checking for NPM"
  npm --version
  if [[ $? != 0 ]] ; then
      echo "Downloading npm"
      git clone git://github.com/isaacs/npm.git && cd npm
      git checkout v${NPM_VERSION}
      make install
  else
      echo "NPM $(npm --version) is already installed"
      echo "Looking for an update"
      npm i -g npm
  fi
    sudo npm install -g bower && bower install

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]
then
  echo 'Install Third-party Javascript Libraries for Linux Platform'
  sudo apt-get update
  sudo apt-get install -y nodejs && sudo apt-get install -y npm && sudo ln -s /usr/bin/nodejs /usr/bin/node
  node -v && npm -v
  sudo npm install -g bower && bower install
elif [ -n "$COMSPEC" -a -x "$COMSPEC" ]
then 
  echo $0: this script does not support Windows \:\(
fi