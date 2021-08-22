#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

PROJECT_GITREPO=${PROJECT_GITREPO:-}
PROJECT_ROOT=${PROJECT_ROOT:-}
UBUNTU_USER=${UBUNTU_USER:ubuntu}

ssh-keyscan github.com >> $HOME/.ssh/known_hosts

if [ ! -v $PROJECT_ROOT ] && [ ! -d $PROJECT_ROOT ]; then
    echo create directory $PROJECT_ROOT and chown to $UBUNTU_USER.
    mkdir -p $PROJECT_ROOT
    chown -R $UBUNTU_USER:$UBUNTU_USER $PROJECT_ROOT
fi

if [ ! -v $PROJECT_GITREPO ] && [ -d $PROJECT_ROOT ]; then
    echo clone project TO $PROJECT_ROOT.
    git clone $PROJECT_GITREPO $PROJECT_ROOT
    chown -R $UBUNTU_USER:$UBUNTU_USER $PROJECT_ROOT
fi