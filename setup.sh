#!/bin/bash
cd expertiza
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml


if [ "$(uname)" == "Darwin" ]
then
  echo 'Install Third-party Javascript Libraries for Mac OS X platform'
  brew update && brew install node && node -v && npm -v
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