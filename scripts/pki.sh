#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
SECRETS="$ROOT_DIR/fabrik/secrets"
mkdir -p "$SECRETS"

openssl rand -hex 32 > "$SECRETS/shared_secret.key"
echo "Generated $SECRETS/shared_secret.key"

