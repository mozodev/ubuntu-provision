#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi
UBUNTU_USER=${UBUNTU_USER:-ubuntu}

# Build Essentials
apt-get update && apt-get install -y curl build-essential 
apt-get install -y automake autoconf autotools-dev

# Install mecab-ko
su - $UBUNTU_USER -c "cd ~/ && curl -L -O https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz && tar zxfv mecab-0.996-ko-0.9.2.tar.gz"
su - $UBUNTU_USER -c "cd ~/mecab-0.996-ko-0.9.2 && ./configure && make && make check"
cd /home/$UBUNTU_USER/mecab-0.996-ko-0.9.2 && make install
cd /home/$UBUNTU_USER/mecab-0.996-ko-0.9.2 && ldconfig

# Install mecab-ko-dic
su - $UBUNTU_USER -c "cd ~/ && curl -L -O https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.1.1-20180720.tar.gz && tar zxfv mecab-ko-dic-2.1.1-20180720.tar.gz"
su - $UBUNTU_USER -c "cd ~/mecab-ko-dic-2.1.1-20180720 && ./autogen.sh && ./configure && make && make check "
cd /home/$UBUNTU_USER/mecab-ko-dic-2.1.1-20180720 && make install
echo "dicdir = /usr/local/lib/mecab/dic/mecab-ko-dic" > /usr/local/etc/mecabrc

# install ruby natto gem if ruby is installed.
su - $UBUNTU_USER -c "if command -v ruby -v &> /dev/null; then gem install natto; fi"

# clean up 
su - $UBUNTU_USER -c "cd ~/ && rm mecab-0.996-ko-0.9.2.tar.gz && rm -rf mecab-0.996-ko-0.9.2"
su - $UBUNTU_USER -c "cd ~/ && rm mecab-ko-dic-2.1.1-20180720.tar.gz && rm -rf mecab-ko-dic-2.1.1-20180720"
