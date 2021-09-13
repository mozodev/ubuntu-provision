#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

RUBY_VERSION=${RUBY_VERSION:-2.7.4}
UBUNTU_USER=${UBUNTU_USER:-ubuntu}

echo [rbenv] install rbenv dependencies
sudo apt-get install -y build-essential autoconf bison libssl-dev libyaml-dev \
libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev

echo [rbenv] install rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | su - $UBUNTU_USER -c "bash"
su - $UBUNTU_USER -c "cd ~/.rbenv && src/configure && make -C src"
su - $UBUNTU_USER -c 'echo '"'"'export PATH=$HOME/.rbenv/bin:$PATH'"'"' >> ~/.bash_profile'
su - $UBUNTU_USER -c 'echo '"'"'eval "$(rbenv init -)"'"'"' >> ~/.bash_profile'

echo [rbenv] install ruby and bundler gem
if [ ! -e .rbenv/versions/$RUBY_VERSION ]; then
  su - $UBUNTU_USER -c "rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION"
  su - $UBUNTU_USER -c "echo 'gem: --no-ri --no-rdoc --no-document --suggestions' >> ~/.gemrc && gem install bundler"
fi

echo [rbenv] check
su - $UBUNTU_USER -c "wget -q 'https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-doctor' -O- | bash"
