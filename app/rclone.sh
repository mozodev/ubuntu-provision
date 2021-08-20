#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:ubuntu}

# install rclone
curl https://rclone.org/install.sh | bash

mkdir -p /home/${UBUNTU_USER}/.config/rclone/
chown -R ${UBUNTU_USER}:${UBUNTU_USER} /home/${UBUNTU_USER}/.config/rclone/

FUSE_ALLOW_OTHER=${FUSE_ALLOW_OTHER:-}
if [ ! -v "$FUSE_ALLOW_OTHER" ]; then
    echo 'user_allow_other' | tee -a /etc/fuse.conf
fi
