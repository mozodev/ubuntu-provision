#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list
apt-get update

apt-get -y -qq install postgresql-13 postgresql-client-13
runuser -l postgres -c 'psql -c "ALTER USER \"postgres\" WITH PASSWORD '"'"'postgres'"'"';"'
runuser -l postgres -c 'psql -c "CREATE DATABASE vagrant TEMPLATE=\"template0\" ENCODING='"'"'utf8'"'"';"'
