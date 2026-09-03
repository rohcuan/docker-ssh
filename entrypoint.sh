#!/usr/bin/env bash
set -euo pipefail

USERNAME="user"
PASSWORD="user"
MARKER="/etc/ssh/.configured"

export DEBIAN_FRONTEND=noninteractive

setup_ssh() {
    apt-get update

    apt-get install -y \
        openssh-server \
        sudo \
        ca-certificates \
        locales

    echo "root:${PASSWORD}" | chpasswd

    if id "${USERNAME}" >/dev/null 2>&1; then
        :
    else
        useradd -m -s /bin/bash "${USERNAME}"
    fi
    echo "${USERNAME}:${PASSWORD}" | chpasswd

    echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-${USERNAME}
    chmod 440 /etc/sudoers.d/99-${USERNAME}

    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

    touch "${MARKER}"
}

if [[ ! -f "${MARKER}" ]]; then
    setup_ssh
else
    echo "SSH already configured, skipping setup"
fi

mkdir -p /run/sshd

exec /usr/sbin/sshd -D -e
