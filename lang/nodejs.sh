#!/bin/bash
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

NODE_VERSION=${NODE_VERSION:-14}
ALLOWED_NODE_VERSIONS=('10', '12', '13', '14', '15')
if [[ "${ALLOWED_NODE_VERSIONS[*]}" =~ "$NODE_VERSION" ]]; then
  echo [nodejs] add repo for v$NODE_VERSION node, yarn
  curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo bash
  curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

  echo [nodejs] install nodejs LTS v$NODE_VERSION and yarn
  sudo apt-get update && sudo apt install -y nodejs yarn
else
  echo "$NODE_VERSION not supported."
  exit 1
fi
