#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

RUBY_VERSION=${RUBY_VERSION:-2.7.4}
UBUNTU_USER=${UBUNTU_USER:-ubuntu}

echo [rbenv] install rbenv dependencies
sudo apt-get install -y build-essential autoconf bison \
libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \
libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev

echo [rbenv] install rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | sudo -u $UBUNTU_USER bash
sudo -u $UBUNTU_USER cd $UBUNTU_USER/.rbenv && sudo -u $UBUNTU_USER src/configure && sudo -u $UBUNTU_USER make -C src
sudo -u $UBUNTU_USER echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/$UBUNTU_USER/.bashrc
sudo -u $UBUNTU_USER echo 'eval "$(rbenv init -)"' >> /home/$UBUNTU_USER/.bashrc

echo [rbenv] install ruby and bundler gem
if [ ! -e .rbenv/versions/$RUBY_VERSION ]; then
  sudo -u $UBUNTU_USER rbenv install $RUBY_VERSION && sudo -u $UBUNTU_USER rbenv global $RUBY_VERSION
  sudo -u $UBUNTU_USER echo 'gem: --no-ri --no-rdoc --no-document --suggestions' >> /home/$UBUNTU_USER/.gemrc
  sudo -u $UBUNTU_USER source ~/.bashrc && sudo -u $UBUNTU_USER gem install bundler && sudo -u $UBUNTU_USER ruby -v
fi
