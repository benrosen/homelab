#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

sudo k3s kubectl apply -f longhorn/kubernetes.yaml