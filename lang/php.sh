#!/bin/bash

if [ -f .env ]; then
  export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

PHP_VERSION=${PHP_VERSION:-7.4}
ALLOWED_PHP_VERSIONS=('5.6', '7.0','7.1', '7.2', '7.3', '7.4', '8.0')
if [[ "${ALLOWED_PHP_VERSIONS[*]}" =~ "$PHP_VERSION" ]]; then
  echo "[php] install php $PHP_VERSION, apache2"
  yes | sudo add-apt-repository ppa:ondrej/php && sudo apt-get update
  sudo apt-get install -y -qq zip unzip apache2 php${PHP_VERSION}-{cli,gd,xml,curl,mbstring,zip,opcache,apcu,mysql,fpm,yaml}
  sudo a2enmod rewrite proxy_fcgi && sudo a2enconf php${PHP_VERSION}-fpm
  
  echo "[php] set config"
  cat <<EOF | sudo tee /etc/php/${PHP_VERSION}/cli/conf.d/php-dev.ini | sudo tee /etc/php/${PHP_VERSION}/fpm/conf.d/php-dev.ini
[PHP]
max_execution_time = 0
max_input_time = 0
memory_limit = -1
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_startup_errors = On
log_errors = On
log_errors_max_len = 1024
date.timezone = Asia/Seoul
upload_max_filesize = 102400M
post_max_size = 0
max_file_uploads=100
EOF
  echo 'php_admin_value[error_log] = /vagrant/fpm-php.www.log' | sudo tee -a /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
else
  echo "$PHP_VERSION not supported."
  exit 1
fi

APACHE_DOCROOT=${APACHE_DOCROOT:-}
if [ ! -z $APACHE_DOCROOT ] && [ -d $APACHE_DOCROOT ]; then
  echo "[apache2] add virtualhost"
  cat <<EOF | sudo tee /etc/apache2/sites-available/vagrant.conf
<VirtualHost *:80>
  ServerAdmin $(git config user.email)
  DocumentRoot $APACHE_DOCROOT
  <Directory $APACHE_DOCROOT>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
EOF
  sudo a2dissite 000-default && sudo a2ensite vagrant && sudo service apache2 reload
fi

echo "[php] install composer"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
