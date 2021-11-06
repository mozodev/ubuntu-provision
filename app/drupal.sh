#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
PROJECT_GITREPO=${PROJECT_GITREPO:-}
PROJECT_ROOT=${PROJECT_ROOT:-}

echo "[php] install drush launcher"
wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar
chmod +x drush.phar && sudo mv drush.phar /usr/local/bin/drush

echo "[php] install coder and drupal coding standard globally"
sudo -u ${UBUNTU_USER} -H -i bash -c 'composer global require drupal/coder dealerdirect/phpcodesniffer-composer-installer'

if [ ! -v $PROJECT_GITREPO ] && [ -d $PROJECT_ROOT ]; then
  echo clone project TO $PROJECT_ROOT.
  git clone $PROJECT_GITREPO $PROJECT_ROOT
  chown -R $UBUNTU_USER:$UBUNTU_USER $PROJECT_ROOT
fi

if [ ! -v $PROJECT_ROOT ] && [ ! -d $PROJECT_ROOT ]; then
  echo create directory $PROJECT_ROOT and chown to $UBUNTU_USER.
  mkdir -p $PROJECT_ROOT
  chown -R $UBUNTU_USER:$UBUNTU_USER $PROJECT_ROOT
  sudo -u ${UBUNTU_USER} -H -i bash -c 'phpcs --config-set installed_paths $PROJECT_ROOT/vendor/drupal/coder/coder_sniffer/'
fi
