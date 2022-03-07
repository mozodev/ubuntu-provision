#!/usr/bin/env bash

# https://betterdev.blog/minimal-safe-bash-script-template/
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
usage() {
  cat <<EOF 
Usage: gh-fetch hugo
Fetch and install specific latest release binary from github.
EOF
  exit
}
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}
msg() {
  echo >&2 -e "${1-}"
}
die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

args=("$@")
[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments: app name."

allowed_apps=(hugo jq yq drupalorg benthos drush-launcher cloudflared)
allowed_app_list=$(IFS=, ; echo "${allowed_apps[*]}")
if ! [[ "${allowed_apps[*]}" =~ "$1" ]]; then
  echo "$1 is not avaliable. ($allowed_app_list)"
  exit 1
fi

# set gh_repo, pattern from $1
case "$1" in
  "hugo") gh_repo="gohugoio/hugo"; pattern="browser_download_url.*hugo_extended.*_Linux-64bit\.tar\.gz" ;;
  "jq") gh_repo="stedolan/jq"; pattern="browser_download_url.*jq-linux64" ;;
  "yq") gh_repo="mikefarah/yq"; pattern="browser_download_url.*yq_linux_amd64" ;;
  "drupalorg") gh_repo="mglaman/drupalorg-cli"; pattern="browser_download_url.*drupalorg.phar" ;;
  "benthos") gh_repo="Jeffail/benthos"; pattern="browser_download_url.*_linux_amd64.tar.gz" ;;
  "drush-launcher") gh_repo="drush-ops/drush-launcher"; pattern="browser_download_url.*drush.phar" ;;
  "cloudflared") gh_repo="cloudflare/cloudflared"; pattern="browser_download_url.*cloudflared-linux-amd64" ;;
  *) gh_repo=""; pattern="" ;;
esac

# get latest binary download url from github api
gh_api_preifx="https://api.github.com/repos"
gh_api_latest_request="$gh_api_preifx/$gh_repo/releases/latest"
status=$(curl -o /dev/null -Isw '%{http_code}' $gh_api_latest_request)
if [ "$status" != "200" ]; then
  # repo not available. api rate limit or mispelling?
  echo "[$status] gh repo not available: $gh_api_latest_request"
  echo "go get some 🌬️ | ☕ | 🚬 (10 min)"
  message=$(curl -s $gh_api_latest_request)
  reset_at=$(curl -H "Accept: application/vnd.github.v3+json" -sSL https://api.github.com/rate_limit | jq .rate.reset | printf '@%s' | xargs date -d @)
  die "$message (after $limit)"
fi

# get only one url
gh_api_latest_url=$(curl -s $gh_api_latest_request | grep $pattern | cut -d ':' -f 2,3)
urls=(${gh_api_latest_url// /})
if [[ ${#urls[@]} > 1 ]]; then
  gh_api_latest_url=${urls[0]}
fi

# install
echo fetching $1 binary from github...
url=$(echo $gh_api_latest_url | tr -d "\"")
if [[ $url == *.tar.gz ]]; then
  curl -sSL $url | tar xz
  # @TODO: CHANGELOG.md, LICENSE, README.md from benthos
  filename=$1
else
  curl -sSL -O $url
  filename=$(basename $url)
fi

if [ ! -v $filename ] && [ -f $filename ]; then
  chmod +x $filename && sudo mv $filename /usr/local/bin/$1
  if [ "hugo" == "$1" ] || [ "drush-launcher" == "$1" ]
  then
    $1 version
  elif [ "benthos" == "$1" ]; then
    $1 -v
  else
    $1 -V
  fi
fi