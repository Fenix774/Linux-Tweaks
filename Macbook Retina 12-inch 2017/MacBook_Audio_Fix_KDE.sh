#!/bin/bash
set -e

# Step 3: Install build dependencies
echo "==> Installing build dependencies..."
sudo dnf install -y git dkms kernel-devel kernel-headers make gcc wget

# Step 4: Clone repo and build/install the module
echo "==> Cloning repository and compiling DKMS module..."
WORKDIR="$(mktemp -d)"
git clone https://github.com/juicecultus/macbook12-audio-driver.git "$WORKDIR"
cd "$WORKDIR"

sudo ./install.cirrus.driver.sh -i

echo "==> Done. Please reboot when convenient."