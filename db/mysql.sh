#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-root}
MYSQL_USER=${MYSQL_USER:-ubuntu}
MYSQL_USER_PASS=${MYSQL_USER_PASS:-ubuntu}
MYSQL_DATABASE=${MYSQL_DATABASE:-ubuntu}
MYSQL_DATADIR=${MYSQL_DATADIR:-}
MYSQL_INITDB=${MYSQL_INITDB:-}
UBUNTU_USER=${UBUNTU_USER:-ubuntu}

echo "[mysql] install mysql-server"
debconf-set-selections <<< "mysql-server    mysql-server/root-pass  password    ${MYSQL_ROOT_PASSWORD}"
debconf-set-selections <<< "mysql-server    mysql-server/re-root-pass   password    ${MYSQL_ROOT_PASSWORD}"
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mysql-server

if [ ! -z "$MYSQL_DATABASE" ] && [ ! -z "$MYSQL_USER" ]; then
  echo "[mysql] create user and database"
  mysql -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  mysql -e "CREATE USER ${MYSQL_USER}@'localhost' IDENTIFIED BY '${MYSQL_USER_PASS}';"
  mysql -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO ${MYSQL_USER}@localhost; FLUSH PRIVILEGES;"
  cat << EOF > ~/.my.cnf
[client]
user=$MYSQL_USER
password=$MYSQL_USER_PASS
EOF
fi

if [ ! -z "$MYSQL_DATADIR" ]; then
  echo "[mysql] move data directory to $MYSQL_DATADIR"
  # https://www.digitalocean.com/community/tutorials/how-to-move-a-mysql-data-directory-to-a-new-location-on-ubuntu-16-04
  mkdir -p "$MYSQL_DATADIR"
  systemctl stop mysql
  rsync -av /var/lib/mysql $MYSQL_DATADIR
  mv /var/lib/mysql /var/lib/mysql.bak
  echo "datadir=$MYSQL_DATADIR" | tee /etc/mysql/mysql.conf.d/60-custom.cnf
  echo "alias /var/lib/mysql/ -> $MYSQL_DATADIR," | tee -a /etc/apparmor.d/tunables/alias
  systemctl restart apparmor
  mkdir /var/lib/mysql/mysql -p
  systemctl start mysql
fi

if [ ! -z "$MYSQL_INITDB" ] && [ -f "$MYSQL_INITDB" ]; then
  echo "[mariadb] $MYSQL_INITDB exists and restoring to $MYSQL_DATABASE"
  gunzip -c $MYSQL_INITDB | mysql $MYSQL_DATABASE
fi
