#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

GO_VERSION=${GO_VERSION:-1.17.0}
UBUNTU_USER=${UBUNTU_USER:-ubuntu}

# https://github.com/syndbg/goenv/blob/master/INSTALL.md
su - $UBUNTU_USER -c "git clone https://github.com/syndbg/goenv.git ~/.goenv"
cat << 'EOF' | tee -a /home/$UBUNTU_USER/.bash_profile
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"
EOF
su - $UBUNTU_USER -c "source ~/.bash_profile && goenv install $GO_VERSION && goenv global $GO_VERSION"
