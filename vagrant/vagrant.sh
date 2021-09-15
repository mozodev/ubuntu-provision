#!/bin/bash

if [ ! "`whoami`" = "root" ]; then
    echo "\nPlease run script as root."
    exit 1
fi

if [ -f /home/vagrant/.env ]; then
  mv /home/vagrant/.env /root/.env
fi

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
USER_PUBLIC_KEY=${USER_PUBLIC_KEY:-}

if [ ! -v $USER_PUBLIC_KEY ] && [ -f $USER_PUBLIC_KEY ]; then
    echo add ssh key to agent.
    cat $USER_PUBLIC_KEY >> /home/$UBUNTU_USER/.ssh/authorized_keys
    eval "$(ssh-agent -s)" && ssh-add
    echo 'eval `ssh-agent` &> /dev/null 2&>1 && ssh-add' >> /home/$UBUNTU_USER/.bashrc
fi

# copy provision files to $UBUNTU_USER
if [ -f /home/vagrant/.gitconfig ]; then
  cp /home/vagrant/.gitconfig /home/$UBUNTU_USER/.gitconfig
  chown $UBUNTU_USER:$UBUNTU_USER /home/$UBUNTU_USER/.gitconfig
fi

if [ -f /home/vagrant/.ssh/id_rsa ]; then
  cp /home/vagrant/.ssh/id_rsa /home/$UBUNTU_USER/.ssh/id_rsa
  chown $UBUNTU_USER:$UBUNTU_USER /home/$UBUNTU_USER/.ssh/id_rsa
fi

if [ -f /home/vagrant/.ssh/id_rsa.pub ]; then
  cp /home/vagrant/.ssh/id_rsa.pub /home/$UBUNTU_USER/.ssh/id_rsa.pub
  chown $UBUNTU_USER:$UBUNTU_USER /home/$UBUNTU_USER/.ssh/id_rsa.pub
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

