#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-root}
MYSQL_USER=${MYSQL_USER:-vagrant}
MYSQL_USER_PASS=${MYSQL_USER_PASS:-vagrant}
MYSQL_DATABASE=${MYSQL_DATABASE:-vagrant}
MYSQL_DATADIR=${MYSQL_DATADIR:-}
MYSQL_INITDB=${MYSQL_INITDB:-/vagrant/dump/dev.sql.gz}

echo "[mysql] install 8"
sudo apt-get update
export DEBIAN_FRONTEND=noninteractive
echo "mysql-community-server mysql-community-server/root-pass password ${MYSQL_ROOT_PASSWORD}" | sudo debconf-set-selections
echo "mysql-community-server mysql-community-server/root-re-pass password ${MYSQL_ROOT_PASSWORD}" | sudo debconf-set-selections
echo "mysql-community-server mysql-server/default-auth-override select Use Legacy Authentication Method (Retain MySQL 5.x Compatibility)" | sudo debconf-set-selections
sudo apt-get install -y -qq mysql-server

echo "[mysql] create user and database"
sudo mysql -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER ${MYSQL_USER}@'localhost' IDENTIFIED BY '${MYSQL_USER_PASS}';"
sudo mysql -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO ${MYSQL_USER}@localhost; FLUSH PRIVILEGES;"

if [ ! -z "$MYSQL_DATADIR" ]; then
    echo "[mysql] move data directory to $MYSQL_DATADIR"
    # https://www.digitalocean.com/community/tutorials/how-to-move-a-mysql-data-directory-to-a-new-location-on-ubuntu-16-04
    sudo mkdir -p "$MYSQL_DATADIR"
    sudo systemctl stop mysql
    sudo rsync -av /var/lib/mysql $MYSQL_DATADIR
    sudo mv /var/lib/mysql /var/lib/mysql.bak
    echo "datadir=$MYSQL_DATADIR" | sudo tee /etc/mysql/mysql.conf.d/60-custom.cnf
    echo "alias /var/lib/mysql/ -> $MYSQL_DATADIR," | sudo tee -a /etc/apparmor.d/tunables/alias
    sudo systemctl restart apparmor
    sudo mkdir /var/lib/mysql/mysql -p
    sudo systemctl start mysql
fi

cat << EOF > ~/.my.cnf
[client]
user=$MYSQL_USER
password=$MYSQL_USER_PASS
EOF

if [ ! -z "$MYSQL_INITDB" ] && [ -f "$MYSQL_INITDB" ]; then
    echo "[mariadb] $MYSQL_INITDB exists and restoring to $MYSQL_DATABASE"
    gunzip -c $MYSQL_INITDB | sudo mysql $MYSQL_DATABASE
fi
