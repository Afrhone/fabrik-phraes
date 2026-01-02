#!/usr/bin/env bash
set -euo pipefail

UNIT_SRC="$(cd "$(dirname "$0")" && pwd)/hypernode.service"
UNIT_DST="/etc/systemd/system/hypernode.service"

echo "Installing systemd service to $UNIT_DST"
sudo cp "$UNIT_SRC" "$UNIT_DST"
echo "Reloading systemd daemon"
sudo systemctl daemon-reload
echo "Enable at boot"
sudo systemctl enable hypernode.service
echo "Start service"
sudo systemctl start hypernode.service
echo "Status:"
sudo systemctl status hypernode.service --no-pager

