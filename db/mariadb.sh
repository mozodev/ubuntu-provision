#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

MARIADB_VERSION=${MARIADB_VERSION:-10.5}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-root}
MYSQL_USER=${MYSQL_USER:-vagrant}
MYSQL_USER_PASS=${MYSQL_USER_PASS:-vagrant}
MYSQL_DATABASE=${MYSQL_DATABASE:-vagrant}
MYSQL_DATADIR=${MYSQL_DATADIR:-}
MYSQL_INITDB=${MYSQL_INITDB:-/vagrant/dump/dev.sql.gz}
UBUNTU_USER=${UBUNTU_USER:-ubuntu}

echo "[mariadb] add $MARIADB_VERSION repository"
apt-get install -y curl apt-transport-https
curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
apt-get update

echo "[mariadb] install $MARIADB_VERSION"
export DEBIAN_FRONTEND=noninteractive
echo "mariadb-server-$MARIADB_VERSION mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections
echo "mariadb-server-$MARIADB_VERSION mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections
apt-get install -y -qq mariadb-server
mysql -uroot -pPASS -e "SET PASSWORD = PASSWORD('');"

echo "[mariadb] create user and database"
mysql -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER ${MYSQL_USER}@'localhost' IDENTIFIED BY '${MYSQL_USER_PASS}';"
mysql -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO ${MYSQL_USER}@localhost; FLUSH PRIVILEGES;"

if [ ! -z "$MYSQL_DATADIR" ]; then
    # https://www.digitalocean.com/community/tutorials/how-to-move-a-mysql-data-directory-to-a-new-location-on-ubuntu-16-04
    mkdir -p "$MYSQL_DATADIR"
    systemctl stop mariadb
    rsync -av /var/lib/mysql $MYSQL_DATADIR
    mv /var/lib/mysql /var/lib/mysql.bak
    echo "datadir=$MYSQL_DATADIR" | tee /etc/mysql/mariadb.conf.d/60-custom.cnf
    echo "alias /var/lib/mysql/ -> $MYSQL_DATADIR," | tee -a /etc/apparmor.d/tunables/alias
    systemctl restart apparmor
    mkdir /var/lib/mysql/mysql -p
    systemctl start mysql
fi

cat << EOF > /home/$UBUNTU_USER/.my.cnf
[client]
user=$MYSQL_USER
password=$MYSQL_USER_PASS
EOF

if [ ! -z "$MYSQL_INITDB" ] && [ -f "$MYSQL_INITDB" ]; then
    echo "[mariadb] $MYSQL_INITDB exists and restoring to $MYSQL_DATABASE"
    gunzip -c $MYSQL_INITDB | mysql $MYSQL_DATABASE
fi
