#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

echo "[php] install wp-cli globally"
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar && sudo mv wp-cli.phar /usr/local/bin/wp

echo "[php] install imagick"
PHP_VERSION=${PHP_VERSION:-8.1}
apt-get -y -qq install php${PHP_VERSION}-imagick
