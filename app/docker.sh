#!/bin/bash
# https://gist.github.com/subfuzion/90e8498a26c206ae393b66804c032b79

UBUNTU_USER=${UBUNTU_USER:ubuntu}

curl -fsSL https://get.docker.com/ | sh
adduser $UBUNTU_USER docker
systemctl restart docker

docker version
docker compose version