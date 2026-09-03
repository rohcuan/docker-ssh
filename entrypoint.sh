#!/usr/bin/env bash
set -euo pipefail

USERNAME="user"
PASSWORD="user"

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y \
    openssh-server \
    sudo \
    ca-certificates \
    locales

echo "root:${PASSWORD}" | chpasswd

if id "${USERNAME}" >/dev/null 2>&1; then
    echo "${USERNAME}:${PASSWORD}" | chpasswd
else
    useradd -m -s /bin/bash "${USERNAME}"
    echo "${USERNAME}:${PASSWORD}" | chpasswd
fi

echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-${USERNAME}
chmod 440 /etc/sudoers.d/99-${USERNAME}

sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

mkdir -p /run/sshd

exec /usr/sbin/sshd -D -e
