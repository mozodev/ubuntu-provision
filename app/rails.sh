#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

# https://guides.rubyonrails.org/development_dependencies_install.html#ubuntu
sudo apt-get install -y imagemagick ffmpeg mupdf mupdf-tools libxml2-dev sqlite3 libsqlite3-dev

RAILS_QUEUE=${RAILS_QUEUE:-false}
if [ "$RAILS_QUEUE" = true ]; then
  sudo apt-get install -y redis-server
fi

RAILS_CACHE=${RAILS_CACHE:-false}
if [ "$RAILS_CACHE" = true ]; then
  sudo apt-get install -y memcached
fi

RAILS_DB="${RAILS_DB:-mysql}"
case $RAILS_DB in
  "mysql")
    sudo apt-get install -y libmysqlclient-dev
    ;;
  "postgresql")
    sudo apt-get install -y libpq-dev
    ;;
esac
