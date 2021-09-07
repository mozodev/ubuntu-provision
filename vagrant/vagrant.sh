#!/bin/bash

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:ubuntu}
USER_PUBLIC_KEY=${USER_PUBLIC_KEY:-}

if [ ! -v $USER_PUBLIC_KEY ] && [ -f $USER_PUBLIC_KEY ]; then
    echo add ssh key to agent.
    cat $USER_PUBLIC_KEY >> ~/.ssh/authorized_keys
    eval "$(ssh-agent -s)" && ssh-add
    echo 'eval `ssh-agent` &> /dev/null 2&>1 && ssh-add' >> ~/.bashrc
fi

# For vscode
echo 'defscrollback 10000' > /home/$UBUNTU_USER/.screenrc
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sudo sysctl -p

cat << 'EOF' >> /home/$UBUNTU_USER/.bashrc
alias up="sudo apt update && sudo apt -y --allow-downgrades upgrade && sudo apt -y autoremove"

# User specific environment and startup programs
if [ -f ~/.env ]; then
	set -o allexport; source ~/.env; set +o allexport
fi

# vscode
if [ -d ~/.vscode-server/bin ]; then
    CODE_DIR=$(ls -td ~/.vscode-server/bin/*/ | head -1)
    export PATH=$PATH:$CODE_DIR/bin/
fi
EOF

