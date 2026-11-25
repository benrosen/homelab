#!/usr/bin/env bash

set -euo pipefail

# Update system
sudo apt update
sudo apt upgrade -y

# Install dependencies
sudo apt install -y curl ca-certificates

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