#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

RUBY_VERSION=${RUBY_VERSION:-3.0.0}

echo [rbenv] install rbenv dependencies
sudo apt-get install -y build-essential autoconf bison \
libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \
libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev

echo [rbenv] install rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
cd ~/.rbenv && src/configure && make -C src
export PATH="$HOME/.rbenv/bin:$PATH" && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
eval "$(rbenv init -)" && echo 'eval "$(rbenv init -)"' >> ~/.bashrc

echo [rbenv] install ruby and bundler gem
if [ ! -e .rbenv/versions/$RUBY_VERSION ]; then
  rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION
  echo 'gem: --no-ri --no-rdoc --no-document --suggestions' >> ~/.gemrc
  source ~/.bashrc && gem install bundler && ruby -v
fi
