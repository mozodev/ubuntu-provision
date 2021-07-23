#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

/bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
echo 'alias hs="hugo server -D -b 0.0.0.0"' >> ~/.bash_aliases
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install hugo
