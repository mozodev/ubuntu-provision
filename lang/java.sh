#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

JAVA_VERSION=${JAVA_VERSION:-11}
ALLOWED_JAVA_VERSIONS=('8', '11', '13', '14')
if [[ "${ALLOWED_JAVA_VERSIONS[*]}" =~ "$JAVA_VERSION" ]]; then
  echo "JAVA_VERSION: $JAVA_VERSION ..."
  sudo apt-get -y install openjdk-$JAVA_VERSION-jre-headless
  java -version
else
  echo "$JAVA_VERSION not supported."
  exit 1
fi
