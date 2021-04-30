#!/bin/bash
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
sudo apt-get update

sudo apt-get -y -qq install postgresql-13 postgresql-client-13
sudo runuser -l postgres -c 'psql -c "ALTER USER \"postgres\" WITH PASSWORD '"'"'postgres'"'"';"'
sudo runuser -l postgres -c 'psql -c "CREATE DATABASE vagrant TEMPLATE=\"template0\" ENCODING='"'"'utf8'"'"';"'
