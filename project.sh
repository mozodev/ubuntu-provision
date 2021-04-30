#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

PROJECT_GITREPO=${PROJECT_GITREPO:-}
PROJECT_ROOT=${PROJECT_ROOT:-}

ssh-keyscan github.com >> $HOME/.ssh/known_hosts

if [ ! -v $PROJECT_ROOT ] && [ ! -d $PROJECT_ROOT ]; then
    echo create directory $PROJECT_ROOT and chown to $USER.
    sudo mkdir -p $PROJECT_ROOT
    sudo chown -R $USER:$USER $PROJECT_ROOT
fi

if [ ! -v $PROJECT_GITREPO ] && [ -d $PROJECT_ROOT ]; then
    echo clone project TO $PROJECT_ROOT.
    git clone $PROJECT_GITREPO $PROJECT_ROOT
fi