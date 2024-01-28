#!/bin/bash

[ -f /root/.env ] && export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
PHP_VERSION=${PHP_VERSION:-8.1}
PHP_ENV=${PHP_ENV:dev}

ALLOWED_PHP_VERSIONS=('5.6', '7.0','7.1', '7.2', '7.3', '7.4', '8.0', '8.1', '8.2', '8.3')
if [[ "${ALLOWED_PHP_VERSIONS[*]}" =~ "$PHP_VERSION" ]]; then
  echo "[php] install php $PHP_VERSION, apache2"
  yes | add-apt-repository ppa:ondrej/php && apt-get update
  apt-get install -y -qq zip unzip apache2 php${PHP_VERSION}-{cli,gd,xml,curl,mbstring,zip,opcache,apcu,mysql,fpm,yaml}
  a2enmod rewrite proxy_fcgi && a2enconf php${PHP_VERSION}-fpm
  
  echo "[php] set common config"
  sed -ie 's/\;date\.timezone\ =/date\.timezone\ =\ Asia\/Seoul/g' /etc/php/$PHP_VERSION/cli/php.ini /etc/php/$PHP_VERSION/fpm/php.ini
  sed -ie 's/memory_limit = .*/memory_limit = '-1'/' /etc/php/$PHP_VERSION/cli/php.ini /etc/php/$PHP_VERSION/fpm/php.ini
  sed -ie 's/post_max_size = .*/post_max_size = '2048G'/' /etc/php/$PHP_VERSION/cli/php.ini /etc/php/$PHP_VERSION/fpm/php.ini

  if [ "$PHP_ENV" == "dev" ]; then
    cat <<EOF | tee -a /etc/php/${PHP_VERSION}/fpm/conf.d/dev.ini
max_execution_time = 0
max_input_time = 0
EOF
  fi

  echo "[php] install composer"
  sudo -u ${UBUNTU_USER} -H -i bash -c 'cd ~/ && curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer'
  chown -R $UBUNTU_USER:$UBUNTU_USER /usr/local/bin && composer -V
  echo 'export PATH="~/.composer/vendor/bin:$PATH"' >> /home/$UBUNTU_USER/.profile
else
  echo "$PHP_VERSION not supported."
  exit 1
fi
