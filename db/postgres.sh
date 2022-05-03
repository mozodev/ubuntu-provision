#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
PSQL_USER=${PSQL_USER:-ubuntu}
PSQL_PASS=${PSQL_PASS:-ubuntu}
PSQL_DBNAME=${PSQL_DBNAME:-ubuntu}
PSQL_DUMP=${PSQL_DUMP:-}
PSQL_LISTEN=${PSQL_LISTEN:-}

echo "[postgres] Installing..."
if [[ $(apt-cache show postgresql | grep State) -eq 0 ]]; then
  apt-get update && apt-get install -y -qq postgresql-all
  systemctl enable postgresql
fi
echo "[postgres] Install completed!"
echo "[postgres] Set config..."
if [ ! -z "$PSQL_LISTEN" ]; then
su - postgres -c "tee /etc/postgresql/12/main/postgresql.conf > /dev/null" <<EOF
listen_addresses = '$PSQL_LISTEN'
EOF
fi

if [ ! -z "$PSQL_DBNAME" ] && [ ! -z "$PSQL_USER" ]; then
  echo "[postgres] create user and database"
  su - postgres <<EOF
  createdb $PSQL_DBNAME;
  psql -c "CREATE USER $PSQL_USER WITH ENCRYPTED PASSWORD '$PSQL_PASS';"
  psql -c "GRANT ALL PRIVILEGES ON DATABASE $PSQL_DBNAME TO $PSQL_USER;"
EOF
  echo "[postgres] User '$PSQL_USER' and database '$PSQL_DBNAME' created."
  su - $UBUNTU_USER -c "tee ~/.pg_service.conf > /dev/null" <<EOF
[$PSQL_DBNAME]
host=127.0.0.1
dbname=$PSQL_DBNAME
user=$PSQL_USER
password=$PSQL_PASS
EOF
  su - $UBUNTU_USER -c "tee -a ~/.bash_profile > /dev/null" <<EOF
export PGSERVICE=$PSQL_DBNAME
EOF
fi

if [ ! -z "$PSQL_DUMP" ] && [ -f "$PSQL_DUMP" ]; then
  echo "[postgres] $PSQL_DUMP exists and restoring to $PSQL_DBNAME"
  su - $UBUNTU_USER -c "pg_restore -d $PSQL_DBNAME $PSQL_DUMP"
fi

systemctl start postgresql
echo "[postgres] end and started!"