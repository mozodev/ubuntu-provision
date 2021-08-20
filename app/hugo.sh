#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:ubuntu}

/bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/${UBUNTU_USER}/.bashrc
echo 'alias hs="hugo server -D -b 0.0.0.0"' >> ~/home/${UBUNTU_USER}/.bash_aliases
sudo -u ${UBUNTU_USER} -H -i bash -c 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
sudo -u ${UBUNTU_USER} -H -i bash -c 'brew install hugo'
