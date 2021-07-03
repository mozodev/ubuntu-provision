#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

# https://gohugo.io/getting-started/installing/#snap-package
sudo snap install hugo --channel=extended
