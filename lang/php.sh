#!/bin/bash

if [ -f .env ]; then
  export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

PHP_VERSION=${PHP_VERSION:-8.0}
ALLOWED_PHP_VERSIONS=('5.6', '7.0','7.1', '7.2', '7.3', '7.4', '8.0')

PROJECT_CODE=${PROJECT_CODE:-}
PROJECT_ENV=${PROJECT_ENV:}
[ ! -z $PROJECT_CODE ] && sudo mkdir -p /var/www/$PROJECT_CODE/web

PHP_UPLOAD_MAX_SIZE=${PHP_UPLOAD_MAX_SIZE:-}
PHP_UPLOAD_MAX_FILES=${PHP_UPLOAD_MAX_FILES:-}

if [[ "${ALLOWED_PHP_VERSIONS[*]}" =~ "$PHP_VERSION" ]]; then
  echo "[php] install php $PHP_VERSION, apache2"
  yes | sudo add-apt-repository ppa:ondrej/php && sudo apt-get update
  sudo apt-get install -y -qq zip unzip apache2 php${PHP_VERSION}-{cli,gd,xml,curl,mbstring,zip,opcache,apcu,mysql,fpm,yaml}
  sudo a2enmod rewrite proxy_fcgi && sudo a2enconf php${PHP_VERSION}-fpm
  
  echo "[php] add timezone"
  cat <<EOF | sudo tee /etc/php/${PHP_VERSION}/cli/conf.d/$PROJECT_CODE.ini | sudo tee /etc/php/${PHP_VERSION}/fpm/conf.d/$PROJECT_CODE.ini
[PHP]
date.timezone = Asia/Seoul
post_max_size = 2048GB
memory_limit = 512MB
EOF

  if [ ! -z $PHP_UPLOAD_MAX_SIZE ]; then
    cat <<EOF | sudo tee /etc/php/${PHP_VERSION}/cli/conf.d/$PROJECT_CODE.ini | sudo tee /etc/php/${PHP_VERSION}/fpm/conf.d/$PROJECT_CODE.ini
upload_max_filesize = $PHP_UPLOAD_MAX_SIZE
EOF
  fi

  if [ ! -z $PHP_UPLOAD_MAX_FILES ]; then
    cat <<EOF | sudo tee /etc/php/${PHP_VERSION}/cli/conf.d/$PROJECT_CODE.ini | sudo tee /etc/php/${PHP_VERSION}/fpm/conf.d/$PROJECT_CODE.ini
max_file_uploads = $PHP_UPLOAD_MAX_FILES
EOF
  fi

  if [ ! -z $PROJECT_ENV ] && [ "$PROJECT_ENV" == "dev" ]; then
    cat <<EOF | sudo tee /etc/php/${PHP_VERSION}/cli/conf.d/$PROJECT_CODE.ini | sudo tee /etc/php/${PHP_VERSION}/fpm/conf.d/$PROJECT_CODE.ini
max_execution_time = 0
max_input_time = 0
memory_limit = -1
EOF
  fi

  echo 'php_admin_value[error_log] = /var/www/$PROJECT_CODE/fpm-php.www.error.log' | sudo tee -a /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
else
  echo "$PHP_VERSION not supported."
  exit 1
fi

if [ ! -z $PROJECT_CODE ] && [ -d /var/www/$PROJECT_CODE/web ]; then
  echo "[apache2] add virtualhost $PROJECT_CODE"
  cat <<EOF | sudo tee /etc/apache2/sites-available/$PROJECT_CODE.conf
<VirtualHost *:80>
  ServerAdmin $(git config user.email)
  DocumentRoot /var/www/$PROJECT_CODE/web
  <Directory /var/www/$PROJECT_CODE/web>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
EOF
  sudo a2dissite 000-default && sudo a2ensite $PROJECT_CODE && sudo service apache2 reload
fi

echo "[php] install composer"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
sudo chown -R $USER:$USER /usr/lobal/bin
