#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

MYSQL_VERSION=${MYSQL_VERSION:-8.0}
ALLOWED_MYSQL_VERSIONS=('5.7', '8.0')

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-root}
MYSQL_USER=${MYSQL_USER:-ubuntu}
MYSQL_USER_PASS=${MYSQL_USER_PASS:-ubuntu}
MYSQL_DATABASE=${MYSQL_DATABASE:-ubuntu}
MYSQL_DATADIR=${MYSQL_DATADIR:-}
MYSQL_INITDB=${MYSQL_INITDB:-}
UBUNTU_USER=${UBUNTU_USER:-ubuntu}

if [[ "${ALLOWED_MYSQL_VERSIONS[*]}" =~ "$MYSQL_VERSION" ]]; the
  echo "[mysql] install version $MYSQL_VERSION"
  if [ "$MYSQL_VERSION" = '5.7' ]; then
    # https://www.how2shout.com/linux/add-repository-to-install-mysql-5-7-on-ubuntu-20-04-lts-linux/
    # add oracle mysql repo for 5.7
    debconf-set-selections <<< "mysql-apt-config/unsupported-platform: ubuntu bionic"
    debconf-set-selections <<< "mysql-apt-config/repo-codename: bionic"
    debconf-set-selections <<< "mysql-apt-config/select-server: mysql-5.7"
    debconf-set-selections <<< "mysql-apt-config/repo-url: http://repo.mysql.com/apt"
    debconf-set-selections <<< "mysql-apt-config/select-product: Ok"
    debconf-set-selections <<< "mysql-apt-config/repo-distro: ubuntu"
    debconf-set-selections <<< "mysql-apt-config/tools-component: mysql-tools"
    curl -sS https://repo.mysql.com//mysql-apt-config_0.8.12-1_all.deb | DEBIAN_FRONTEND=noninteractive apt -y install
    # install 5.7
    debconf-set-selections <<< "mysql-server-5.7    mysql-server/root_password  ${MYSQL_ROOT_PASSWORD}"
    debconf-set-selections <<< "mysql-server-5.7    mysql-server/root_password_again    ${MYSQL_ROOT_PASSWORD}"
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mysql-server=5.7.36-1ubuntu18.04
  else
    # install 8.0
    debconf-set-selections <<< "mysql-server    mysql-server/root-pass  password    ${MYSQL_ROOT_PASSWORD}"
    debconf-set-selections <<< "mysql-server    mysql-server/re-root-pass   password    ${MYSQL_ROOT_PASSWORD}"
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mysql-server
  fi
fi

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
