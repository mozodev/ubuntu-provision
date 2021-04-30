#!/bin/bash

# install rclone
curl https://rclone.org/install.sh | sudo bash

RCLONE_CONF=${RCLONE_CONF:-}
if [ -f "$RCLONE" ]; then
    mkdir -p ~/.config/rclone/
    cp $RCLONE ~/.config/rclone/
fi

FUSE_CONF=${FUSE_CONF:-}
if [ -f "$FUSE" ]; then
    yes | cp $FUSE /etc/fuse.conf
fi
sudo mkdir -p /data && sudo chown $USER:$USER /data

if [ -f ~/.config/rclone/rclone.conf ]; then
    rclone mount drive: /data --allow-other --daemon
fi

