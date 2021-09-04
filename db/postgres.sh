#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

PSQL_USER=${PSQL_USER:-ubuntu}
PSQL_USER_PASS=${PSQL_USER_PASS:-ubuntu}
PSQL_DATABASE=${PSQL_DATABASE:-ubuntu}

apt-get -y -qq install postgresql-all
runuser -l postgres -c 'psql -c "ALTER USER \"$PSQL_USER\" WITH PASSWORD '" "';"'
runuser -l postgres -c 'psql -c "CREATE DATABASE $PSQL_DATABASE TEMPLATE=\"template0\" ENCODING='"'"'utf8'"'"';"'
