#!/bin/bash

curl -fsSL https://code-server.dev/install.sh | sudo sh
sudo systemctl enable code-server@$USER
sudo systemctl start code-server@$USER

echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" | tee -a /etc/apt/sources.list.d/caddy-fury.list
sudo apt update && sudo apt -y -qq install caddy

HOST=${HOST:-}
if [ ! -z $HOST ]; then
    echo "127.0.0.1 $HOST" | sudo tee -a /etc/hosts
    echo "$HOST" | sudo tee /etc/caddy/Caddyfile
    echo "reverse_proxy 127.0.0.1:8080" | sudo tee -a /etc/caddy/Caddyfile
fi
