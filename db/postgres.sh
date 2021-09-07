#!/bin/bash
set -e

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
PSQL_USER=${PSQL_USER:-ubuntu}
PSQL_PASS=${PSQL_PASS:-ubuntu}
PSQL_DBNAME=${PSQL_DBNAME:-ubuntu}
PSQL_RESTORE=${PSQL_RESTORE:-}

apt-cache show postgresql | grep State
if [ "$?" -gt "0" ]; then
    apt-get install -y -qq postgresql-all
else
    echo "[postgres] Installed!"
fi

if [ ! -z "$PSQL_DBNAME" ] && [ ! -z "$PSQL_USER" ]; then
  echo "[postgres] create user and database"
  su - postgres <<EOF
  createdb $PSQL_DBNAME;
  psql -c "CREATE USER $PSQL_USER WITH ENCRYPTED PASSWORD '$PSQL_PASS';"
  psql -c "GRANT ALL PRIVILEGES ON DATABASE $PSQL_DBNAME TO $PSQL_USER;"
EOF
  echo "[postgres] User '$PSQL_USER' and database '$PSQL_DBNAME' created."
  su - $UBUNTU_USER -c "tee /home/$UBUNTU_USER/.pg_service.conf > /dev/null" <<EOF
[$PSQL_DBNAME]
host=127.0.0.1
dbname=$PSQL_DBNAME
user=$PSQL_USER
password=$PSQL_PASS
EOF
fi

if [ ! -z "$PSQL_RESTORE" ] && [ -f "$PSQL_RESTORE" ]; then
  echo "[postgres] $PSQL_RESTORE exists and restoring to $PSQL_DBNAME"
fi
