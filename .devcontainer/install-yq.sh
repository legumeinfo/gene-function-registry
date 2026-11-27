#!/usr/bin/env bash
set -euo pipefail

if command -v yq >/dev/null 2>&1; then
	yq --version
	exit 0
fi

install_dir="$HOME/.local/bin"
mkdir -p "$install_dir"
curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o "$install_dir/yq"
chmod +x "$install_dir/yq"
"$install_dir/yq" --version
