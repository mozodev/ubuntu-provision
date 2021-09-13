#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:ubuntu}
pushd /tmp/
curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
| grep "browser_download_url.*hugo_extended.*_Linux-64bit\.tar\.gz" \
| cut -d ":" -f 2,3 \
| tr -d \" \
| wget -qi -

tarball="$(find . -name "*Linux-64bit.tar.gz")"
tar -xzf $tarball
chmod 755 hugo && chown $UBUNTU_USER:$UBUNTU_USER hugo
mv hugo /usr/local/bin/
popd
location="$(which hugo)"
echo "Hugo binary location: $location"
version="$(hugo version)"
echo "Hugo binary version: $version"
