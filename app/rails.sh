#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

# https://guides.rubyonrails.org/development_dependencies_install.html#ubuntu
apt-get install -y imagemagick ffmpeg mupdf mupdf-tools libxml2-dev sqlite3 libsqlite3-dev

RAILS_QUEUE=${RAILS_QUEUE:-false}
if [ "$RAILS_QUEUE" = true ]; then
  apt-get install -y redis-server
fi

RAILS_CACHE=${RAILS_CACHE:-false}
if [ "$RAILS_CACHE" = true ]; then
  apt-get install -y memcached
fi

RAILS_DB="${RAILS_DB:-mysql}"
case $RAILS_DB in
  "mysql")
    apt-get install -y libmysqlclient-dev mysql-client
    ;;
  "postgresql")
    apt-get install -y libpq-dev postgresql-client
    ;;
esac

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
RAILS_PRE="${RAILS_PRE:-false}"
if [ "$RAILS_PRE" = true ]; then
  su - $UBUNTU_USER -c "gem install rails --prerelease"
else
  su - $UBUNTU_USER -c "gem install rails"
fi
