#!/bin/bash
if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
echo [nodejs] install node, yarn
su - $UBUNTU_USER -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
su - $UBUNTU_USER -c 'echo "export NVM_DIR=$HOME/.nvm" >> .bash_profile'
su - $UBUNTU_USER -c 'echo "[ -s $NVM_DIR/nvm.sh ] && \. $NVM_DIR/nvm.sh" >> .bash_profile'
su - $UBUNTU_USER -c "nvm install 'lts/*' && nvm alias default 'lts/*' && npm -g i npm yarn"
