#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
PHP_VERSION=${PHP_VERSION:-8.0}
ALLOWED_PHP_VERSIONS=('5.6', '7.0','7.1', '7.2', '7.3', '7.4', '8.0')

PROJECT_CODE=${PROJECT_CODE:-}
PROJECT_ENV=${PROJECT_ENV:-}
PROJECT_GITREPO=${PROJECT_GITREPO:-}
PROJECT_ROOT=${PROJECT_ROOT:-}

PHP_UPLOAD_MAX_SIZE=${PHP_UPLOAD_MAX_SIZE:-}
PHP_UPLOAD_MAX_FILES=${PHP_UPLOAD_MAX_FILES:-}

if [[ "${ALLOWED_PHP_VERSIONS[*]}" =~ "$PHP_VERSION" ]]; then
  echo "[php] install php $PHP_VERSION, apache2"
  yes | add-apt-repository ppa:ondrej/php && apt-get update
  apt-get install -y -qq zip unzip apache2 php${PHP_VERSION}-{cli,gd,xml,curl,mbstring,zip,opcache,apcu,mysql,fpm,yaml}
  a2enmod rewrite proxy_fcgi && a2enconf php${PHP_VERSION}-fpm
  
  echo "[php] set common config"
  sed -ie 's/\;date\.timezone\ =/date\.timezone\ =\ Asia\/Seoul/g' /etc/php/$PHP_VERSION/cli/php.ini /etc/php/$PHP_VERSION/fpm/php.ini
  sed -ie 's/memory_limit = .*/memory_limit = '-1'/' /etc/php/$PHP_VERSION/cli/php.ini /etc/php/$PHP_VERSION/fpm/php.ini
  sed -ie 's/post_max_size = .*/post_max_size = '2048G'/' /etc/php/$PHP_VERSION/cli/php.ini /etc/php/$PHP_VERSION/fpm/php.ini

  if [ ! -z $PHP_UPLOAD_MAX_SIZE ]; then
    cat <<EOF | tee -a /etc/php/${PHP_VERSION}/cli/conf.d/$PROJECT_CODE.ini | tee -a /etc/php/${PHP_VERSION}/fpm/conf.d/$PROJECT_CODE.ini
upload_max_filesize = $PHP_UPLOAD_MAX_SIZE
EOF
  fi

  if [ ! -z $PHP_UPLOAD_MAX_FILES ]; then
    cat <<EOF | tee -a /etc/php/${PHP_VERSION}/cli/conf.d/$PROJECT_CODE.ini | tee -a /etc/php/${PHP_VERSION}/fpm/conf.d/$PROJECT_CODE.ini
max_file_uploads = $PHP_UPLOAD_MAX_FILES
EOF
  fi

  if [ ! -z $PROJECT_ENV ] && [ "$PROJECT_ENV" == "dev" ]; then
    cat <<EOF | tee -a /etc/php/${PHP_VERSION}/cli/conf.d/$PROJECT_CODE.ini | tee -a /etc/php/${PHP_VERSION}/fpm/conf.d/$PROJECT_CODE.ini
max_execution_time = 0
max_input_time = 0
EOF
  fi
else
  echo "$PHP_VERSION not supported."
  exit 1
fi

[ ! -d $PROJECT_ROOT ] && mkdir -p $PROJECT_ROOT
if [ ! -v $PROJECT_GITREPO ] && [ -d $PROJECT_ROOT ]; then
  echo clone project TO $PROJECT_ROOT.
  chown -R $UBUNTU_USER:$UBUNTU_USER $PROJECT_ROOT
  sudo -u ${UBUNTU_USER} -H -i bash -c "git clone $PROJECT_GITREPO $PROJECT_ROOT"
fi

if [ ! -z $PROJECT_CODE ] && [ -d $PROJECT_ROOT/web ]; then
  echo "[apache2] add virtualhost $PROJECT_CODE"
  cat <<EOF | tee /etc/apache2/sites-available/$PROJECT_CODE.conf
<VirtualHost *:80>
  DocumentRoot $PROJECT_ROOT/web
  <Directory $PROJECT_ROOT/web>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
EOF
  echo "php_admin_value[error_log] = /var/www/$PROJECT_CODE/fpm-php.error.log" | tee -a /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
  a2dissite 000-default && a2ensite $PROJECT_CODE && service apache2 reload
fi

echo "[php] install composer"
curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
chown -R $UBUNTU_USER:$UBUNTU_USER /usr/local/bin && composer -V
echo 'export PATH="~/.composer/vendor/bin:$PATH"' >> /home/$UBUNTU_USER/.profile
