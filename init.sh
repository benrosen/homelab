#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

# Initialize node
sudo apt update
sudo apt upgrade -y

sudo apt install -y \
    curl \
    ca-certificates \
    open-iscsi \
    nfs-common \
    smartmontools \
    cryptsetup

printf 'iscsi_tcp\ndm_crypt\n' | \
    sudo tee /etc/modules-load.d/longhorn.conf >/dev/null

sudo rm -f /etc/modules-load.d/iscsi.conf
sudo modprobe iscsi_tcp
sudo modprobe dm_crypt
sudo systemctl enable --now iscsid

# Initialize Kubernetes
if ! command -v k3s >/dev/null 2>&1; then
    curl -sfL https://get.k3s.io | sudo sh -
fi

sudo k3s kubectl wait \
    --for=create node/"$(hostname)" \
    --timeout=180s

sudo k3s kubectl wait \
    --for=condition=Ready node/"$(hostname)" \
    --timeout=180s

# Initialize storage
sudo k3s kubectl apply -f longhorn/kubernetes.yaml

sudo k3s kubectl wait \
    --for=create daemonset/longhorn-manager \
    -n longhorn-system \
    --timeout=300s

sudo k3s kubectl rollout status \
    daemonset/longhorn-manager \
    -n longhorn-system \
    --timeout=600s

sudo k3s kubectl wait \
    --for=create storageclass/longhorn \
    --timeout=300s

sudo k3s kubectl wait \
    --for=create csidriver/driver.longhorn.io \
    --timeout=300s

# Initialize applications
bash postgres/init.sh