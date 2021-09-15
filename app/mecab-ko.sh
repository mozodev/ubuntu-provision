#!/bin/bash

if [ ! "`whoami`" = "root" ]; then
  echo "\nPlease run this script as root."
  exit 1
fi

# Build Essentials
apt-get update && apt-get install -y -qq curl build-essential automake autoconf autotools-dev

# Install mecab-ko
cd /root && curl -sSL https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz | tar xz
cd /root/mecab-0.996-ko-0.9.2 && ./configure && make && make check && make install && ldconfig

# Install mecab-ko-dic
cd /root && curl -sSL https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.1.1-20180720.tar.gz | tar xz
cd /root/mecab-ko-dic-2.1.1-20180720 && ./autogen.sh && ./configure && make && make check && make install
echo "dicdir = /usr/local/lib/mecab/dic/mecab-ko-dic" > /usr/local/etc/mecabrc

# install ruby natto gem if ruby is installed.
if command -v ruby -v &> /dev/null; then gem install natto; fi

# clean up 
rm -rf /root/mecab-0.996-ko-0.9.2 /root/mecab-ko-dic-2.1.1-20180720
