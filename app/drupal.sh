#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

PROJECT_ROOT=${PROJECT_ROOT:-}

echo "[php] install drush launcher"
wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar
chmod +x drush.phar && sudo mv drush.phar /usr/local/bin/drush

echo "[php] install coder and drupal coding standard globally"
composer global require drupal/coder dealerdirect/phpcodesniffer-composer-installer

if [ ! -z "$PROJECT_ROOT" ] && [ -d "$PROJECT_ROOT" ]; then
    phpcs --config-set installed_paths $PROJECT_ROOT/vendor/drupal/coder/coder_sniffer/
fi