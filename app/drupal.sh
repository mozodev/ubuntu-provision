#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
PROJECT_ROOT=${PROJECT_ROOT:-}

# available database: sqlite|mysql|pgsql
DRUPAL_DB_DRIVER=${DRUPAL_DB_DRIVER:-mysql}
case "$DRUPAL_DB_DRIVER" in
  "sqlite") apt-get install -y -qq sqlite3 php-sqlite3 ;;
  "mysql") apt-get install -y -qq mysql-client php-mysql ;;
  "pgsql") apt-get install -y -qq postgresql-client php-pgsql ;;
  *) echo "Unknown database for drupal: ${DRUPAL_DB_DRIVER}" ;;
esac

echo "[php] install drush launcher"
wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar
chmod +x drush.phar && sudo mv drush.phar /usr/local/bin/drush

echo "[php] install coder and drupal coding standard globally"
sudo -u ${UBUNTU_USER} -H -i bash -c '/usr/local/bin/composer global require drupal/coder dealerdirect/phpcodesniffer-composer-installer'

if [ ! -v $PROJECT_ROOT ] && [ ! -d $PROJECT_ROOT ]; then
  sudo -u ${UBUNTU_USER} -H -i bash -c 'phpcs --config-set installed_paths $PROJECT_ROOT/vendor/drupal/coder/coder_sniffer/'
fi