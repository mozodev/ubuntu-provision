#!/bin/bash

if [ ! "`whoami`" = "root" ]; then
  echo "\nPlease run script as root."
  exit 1
fi

if [ -f /root/.env ]; then
  export $(cat /root/.env | grep -v '#' | awk '/=/ {print $1}')
fi

UBUNTU_SWAP=${UBUNTU_SWAP:-1G}

echo "[bootstrap] ubuntu version"
lsb_release -a

echo "[bootstrap] house keeping"
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

apt-get -y -qq update && apt-get -y -qq upgrade && apt-get -y -qq autoremove
apt-get install -y -qq debconf-utils sqlite3 gh curl apt-transport-https
timedatectl set-timezone Asia/Seoul && date

if [[ $(swapon -s | wc -l) -lt 1 ]]; then
  echo "[boostrap] adding swap file"
  fallocate -l ${UBUNTU_SWAP} /swapfile && chmod 600 /swapfile
  mkswap /swapfile && swapon /swapfile
  echo '/swapfile none swap defaults 0 0' | tee -a /etc/fstab
fi

UBUNTU_PERMIT_PASS=${UBUNTU_PERMIT_PASS:-false}
if [ "$UBUNTU_PERMIT_PASS" = true ]; then
  echo "[bootstrap] permit password login"
  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  service sshd restart
fi

UBUNTU_USER=${UBUNTU_USER:-ubuntu}
UBUNTU_USER_PASS=${UBUNTU_USER_PASS:-ubuntu}
UBUNTU_USER_SUDO=${UBUNTU_USER_SUDO:-false}

if ! id "$UBUNTU_USER" &>/dev/null; then
  echo [bootstrap] add user $UBUNTU_USER
  adduser --gecos "" --disabled-password $UBUNTU_USER
  chpasswd <<< "$UBUNTU_USER:$UBUNTU_USER_PASS"
  echo [bootstrap] added $UBUNTU_USER user
  if [ "$UBUNTU_USER_SUDO" = true ] ; then
    if ! groups "$UBUNTU_USER" | grep -q '\bsudo\b' ; then
      usermod -aG sudo $UBUNTU_USER
      echo "$UBUNTU_USER ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/${UBUNTU_USER}
      echo [bootstrap] added $UBUNTU_USER to sudoers
    else
      echo [bootstrap] $UBUNTU_USER is already sudoer.
    fi
  fi
else
  echo [bootstrap] $UBUNTU_USER exists.
fi

echo [bootstrap] add aliases.
echo 'alias up="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"' >> /home/$UBUNTU_USER/.bash_aliases

echo [bootstrap] ssh key, github
ssh-keyscan github.com >> /home/$UBUNTU_USER/.ssh/known_hosts
if [ -f /root/.ssh/id_rsa ]; then
  cp /root/.ssh/id_rsa /home/$UBUNTU_USER/.ssh/
  chmod 400 /home/$UBUNTU_USER/.ssh/
EOF
fi

echo [bootstrap] vscode
echo 'defscrollback 10000' > /home/$UBUNTU_USER/.screenrc
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p
cat << 'EOF' >> /home/$UBUNTU_USER/.bashrc

# vscode
if [ -d ~/.vscode-server/bin ]; then
  CODE_DIR=$(ls -td ~/.vscode-server/bin/*/ | head -1)
  export PATH=$PATH:$CODE_DIR/bin/
fi
EOF

cat << 'EOF' >> /home/$UBUNTU_USER/.bash_profile
source .bashrc
EOF

chown -R $UBUNTU_USER:$UBUNTU_USER /home/$UBUNTU_USER
