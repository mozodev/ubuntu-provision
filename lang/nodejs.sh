#!/bin/bash
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

NODE_VERSION=${NODE_VERSION:-14}
ALLOWED_NODE_VERSIONS=('10', '12', '13', '14', '15')
if [[ "${ALLOWED_NODE_VERSIONS[*]}" =~ "$NODE_VERSION" ]]; then
  echo [nodejs] add repo for v$NODE_VERSION node, yarn
  curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash
  apt install -y nodejs
  npm -g i npm
else
  echo "$NODE_VERSION not supported."
  exit 1
fi
