#!/bin/bash

# check if ubuntu codename exists
. /etc/os-release
if [ -z "$VERSION_CODENAME" ]; then
 exit -1
fi

CFL_BINARY=/usr/local/bin/cloudflared
if [ -f "$CFL_BINARY" ]; then
  sudo rm "$CFL_BINARY"
fi

# Add cloudflare gpg key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $VERSION_CODENAME main" | sudo tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
sudo apt-get update && sudo apt-get install cloudflared
