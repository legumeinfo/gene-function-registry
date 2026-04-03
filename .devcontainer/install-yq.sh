#!/bin/bash
set -e

echo "Installing yq..."

# Download and install yq
mkdir -p /tmp/yq-install
cd /tmp/yq-install
curl -L -o yq.tar.gz https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz
tar -xzf yq.tar.gz
mv yq /usr/local/bin/yq
chmod +x /usr/local/bin/yq
cd /
rm -rf /tmp/yq-install

echo "yq installed successfully at $(which yq)"
yq --version
