#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
PHP_ENV=${PHP_ENV:dev}
DRUPAL_DB_DRIVER=${DRUPAL_DB_DRIVER:-mariadb}
PROJECT_REPO=${PROJECT_REPO:-}
PROJECT_ROOT=${PROJECT_ROOT:-}
PROJECT_HOST=${PROJECT_HOST:-}

case "$DRUPAL_DB_DRIVER" in
  "sqlite") apt-get install -y -qq sqlite3 php-sqlite3 ;;
  "mariadb") apt-get install -y -qq mariadb-client php-mysql ;;
  "pgsql") apt-get install -y -qq postgresql-client php-pgsql ;;
  *) echo "Unknown database for drupal: ${DRUPAL_DB_DRIVER}" ;;
esac

if [ ! -v $PROJECT_REPO ] && [ ! -v $PROJECT_ROOT ]; then
  CHUNKS=(`echo $PROJECT_REPO | tr "/" "\n"`)
  CODENAME=${CHUNKS[1]}
  if git clone git@github.com:${PROJECT_REPO}.git ${PROJECT_ROOT}; then
    echo "$PROJECT_REPO cloned... composer install -o -y"
    sudo -u ${UBUNTU_USER} -H -i bash -c 'composer install -o -y'
    if [ ! -v $PROJECT_HOST ]; then
      echo "#### $CODENAME
<VirtualHost *:80>
  ServerName $PROJECT_HOST
  DocumentRoot $PROJECT_ROOT/web
  <Directory $PROJECT_ROOT/web>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>" > /etc/apache2/sites-available/$CODENAME.conf
      a2ensite $CODENAME.conf && systemctl restart apache2
      echo "Running $PROJECT_HOST... ($PROJECT_ROOT)"
    fi
  else
    echo "Cloning $PROJECT_REPO failed."
  fi
fi

if [ "$PHP_ENV" == "dev" ]; then
  echo "[php] install coder and drupal coding standard globally"
  sudo -u ${UBUNTU_USER} -H -i bash -c '/usr/local/bin/composer global require drupal/coder dealerdirect/phpcodesniffer-composer-installer'
  if [ ! -v $PROJECT_ROOT ] && [ ! -d $PROJECT_ROOT ]; then
    sudo -u ${UBUNTU_USER} -H -i bash -c "$PROJECT_ROOT/vendor/bin/phpcs --config-set installed_paths $PROJECT_ROOT/vendor/drupal/coder/coder_sniffer/"
  fi
fi
