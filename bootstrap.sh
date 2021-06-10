#!/bin/bash

if [ ! "`whoami`" = "root" ]; then
    echo "\nPlease run script as root."
    exit 1
fi

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_SWAP=${UBUNTU_SWAP:-1G}

echo "[bootstrap] ubuntu version"
lsb_release -a

echo "[bootstrap] house keeping"
apt-get -y -qq update && apt-get -y -qq upgrade && apt-get -y -qq autoremove
timedatectl set-timezone Asia/Seoul && date

echo "[boostrap] adding swap file"
fallocate -l ${UBUNTU_SWAP} /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap defaults 0 0' | tee -a /etc/fstab

UBUNTU_PERMIT_PASS=${UBUNTU_PERMIT_PASS:-false}
if [ "$UBUNTU_PERMIT_PASS" = true ]; then
    echo "[bootstrap] permit password login"
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    service sshd restart
fi

UBUNTU_USER_ID=${UBUNTU_USER_ID:-ubuntu}
UBUNTU_USER_PASS=${UBUNTU_USER_PASS:-ubuntu}
UBUNTU_USER_SUDO=${UBUNTU_USER_SUDO:-false}

if ! id "$UBUNTU_USER_ID" &>/dev/null; then
    echo [bootstrap] add user $UBUNTU_USER_ID
    adduser --gecos "" --disabled-password $UBUNTU_USER_ID
    chpasswd <<< "$UBUNTU_USER_ID:$UBUNTU_USER_PASS"
    echo [bootstrap] added $UBUNTU_USER_ID user
    if [ "$UBUNTU_USER_SUDO" = true ] ; then
        if ! groups "$UBUNTU_USER_ID" | grep -q '\bsudo\b' ; then
            usermod -aG sudo $UBUNTU_USER_ID
            echo "$UBUNTU_USER_ID ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/${UBUNTU_USER_ID}
            echo [bootstrap] added $UBUNTU_USER_ID to sudoers
        else
            echo [bootstrap] $UBUNTU_USER_ID is already sudoer.
        fi
    fi
else
    echo [bootstrap] $UBUNTU_USER_ID exists.
fi
