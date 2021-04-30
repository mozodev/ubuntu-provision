#!/bin/bash

curl -fsSL https://get.docker.com | sh
usermod -aG docker vagrant

curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

docker version
docker-compose version
