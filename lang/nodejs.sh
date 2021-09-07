#!/bin/bash
if [ -f .env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

NODE_VERSION=${NODE_VERSION:-14}
UBUNTU_USER=${UBUNTU_USER:-ubuntu}
ALLOWED_NODE_VERSIONS=('10', '12', '13', '14', '15', '16')
if [[ "${ALLOWED_NODE_VERSIONS[*]}" =~ "$NODE_VERSION" ]]; then
  echo [nodejs] add repo for v$NODE_VERSION node, yarn
  su - $UBUNTU_USER -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash"
  su - $UBUNTU_USER -c 'echo "export NVM_DIR=$HOME/.nvm" >> .bash_profile'
  su - $UBUNTU_USER -c 'echo "[ -s $NVM_DIR/nvm.sh ] && \. $NVM_DIR/nvm.sh" >> .bash_profile'
  su - $UBUNTU_USER -c "nvm install 'lts/*' && nvm alias default 'lts/*' && npm -g i npm yarn"
else
  echo "$NODE_VERSION not supported."
  exit 1
fi
