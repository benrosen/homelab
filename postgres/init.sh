#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

# Initialize credentials if they don't already exist
if [[ -z "$(sudo k3s kubectl get secret postgres \
    --ignore-not-found -o name)" ]]; then

    read -rs -p "PostgreSQL password: " PASSWORD
    echo

    if [[ -z "$PASSWORD" ]]; then
        echo "Password cannot be empty." >&2
        exit 1
    fi

    sudo k3s kubectl create secret generic postgres \
        --from-literal=password="$PASSWORD"

    unset PASSWORD
fi

# Apply Kubernetes configuration
sudo k3s kubectl apply -f kubernetes.yaml

# Wait for PostgreSQL to become ready
sudo k3s kubectl rollout status statefulset/postgres \
    --timeout=300s