#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

MARIADB_VERSION=${MARIADB_VERSION:-10.5}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-root}
MYSQL_USER=${MYSQL_USER:-vagrant}
MYSQL_USER_PASS=${MYSQL_USER_PASS:-vagrant}
MYSQL_DATABASE=${MYSQL_DATABASE:-vagrant}
MYSQL_DATADIR=${MYSQL_DATADIR:-}
MYSQL_INITDB=${MYSQL_INITDB:-/vagrant/dump/dev.sql.gz}

echo "[mariadb] add $MARIADB_VERSION repository"
sudo apt-get install -y curl apt-transport-https
curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
sudo apt-get update

echo "[mariadb] install $MARIADB_VERSION"
export DEBIAN_FRONTEND=noninteractive
echo "mariadb-server-$MARIADB_VERSION mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}" | sudo debconf-set-selections
echo "mariadb-server-$MARIADB_VERSION mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}" | sudo debconf-set-selections
sudo apt-get install -y -qq mariadb-server
mysql -uroot -pPASS -e "SET PASSWORD = PASSWORD('');"

echo "[mariadb] create user and database"
sudo mysql -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER ${MYSQL_USER}@'localhost' IDENTIFIED BY '${MYSQL_USER_PASS}';"
sudo mysql -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO ${MYSQL_USER}@localhost; FLUSH PRIVILEGES;"

if [ ! -z "$MYSQL_DATADIR" ]; then
    # https://www.digitalocean.com/community/tutorials/how-to-move-a-mysql-data-directory-to-a-new-location-on-ubuntu-16-04
    sudo mkdir -p "$MYSQL_DATADIR"
    sudo systemctl stop mariadb
    sudo rsync -av /var/lib/mysql $MYSQL_DATADIR
    sudo mv /var/lib/mysql /var/lib/mysql.bak
    echo "datadir=$MYSQL_DATADIR" | sudo tee /etc/mysql/mariadb.conf.d/60-custom.cnf
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
