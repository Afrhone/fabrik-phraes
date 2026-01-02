#!/usr/bin/env bash
set -euo pipefail

# Append a hosts entry mapping 'mongo' to a provided IP (default 127.0.0.1)
# Requires sudo/root.

IP="${1:-127.0.0.1}"
HOSTS_FILE="/etc/hosts"
STAMP="# fabrik mongo entry"

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (use sudo)." >&2
  exit 1
fi

cp -a "$HOSTS_FILE" "${HOSTS_FILE}.bak.$(date +%s)"

tmp="$(mktemp)"
grep -vE "\s+mongo(\s|$)" "$HOSTS_FILE" > "$tmp" || true
printf "%s mongo %s\n" "$IP" "$STAMP" >> "$tmp"
cat "$tmp" > "$HOSTS_FILE"
rm -f "$tmp"

echo "Added: $IP mongo ($STAMP)" >&2

