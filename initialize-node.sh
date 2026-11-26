#!/usr/bin/env bash

set -euo pipefail

# Update system
sudo apt update
sudo apt upgrade -y

# Install dependencies
sudo apt install -y \
    curl \
    ca-certificates \
    open-iscsi \
    nfs-common \
    smartmontools \
    cryptsetup

# Configure kernel modules for Longhorn
printf 'iscsi_tcp\ndm_crypt\n' | \
    sudo tee /etc/modules-load.d/longhorn.conf >/dev/null

sudo rm -f /etc/modules-load.d/iscsi.conf

sudo modprobe iscsi_tcp
sudo modprobe dm_crypt

# Enable iSCSI
sudo systemctl enable --now iscsid

# Install K3s if not already installed
if ! command -v k3s >/dev/null 2>&1; then
    curl -sfL https://get.k3s.io | sudo sh -
fi

# Wait for the node to register
sudo k3s kubectl wait \
    --for=create node/"$(hostname)" \
    --timeout=180s

# Wait for the node to become ready
sudo k3s kubectl wait \
    --for=condition=Ready node/"$(hostname)" \
    --timeout=180s

sudo k3s kubectl get nodes