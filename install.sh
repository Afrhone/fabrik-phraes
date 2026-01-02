#!/usr/bin/env bash
set -euo pipefail

DEST_DIR=${DEST_DIR:-/srv/fabrik-phraes}
RELEASE_URL=${FABRIK_PHRAES_URL:-}

echo "[install] Fabrik‑Phraes installer"
if [[ -z "$RELEASE_URL" ]]; then
  echo "[install] FABRIK_PHRAES_URL not set."
  echo "[install] Set to a published tarball URL (e.g., a GitHub Release)."
  echo "[install] Example: export FABRIK_PHRAES_URL=\"https://github.com/<org>/<repo>/releases/download/v0.1.0/fabrik-phraes.tar.gz\""
  exit 2
fi

TMP=$(mktemp -d)
echo "[install] Downloading bundle..."
curl -fsSL "$RELEASE_URL" -o "$TMP/fabrik-phraes.tar.gz"
mkdir -p "$DEST_DIR"
tar -xzf "$TMP/fabrik-phraes.tar.gz" -C "$DEST_DIR" --strip-components=1

echo "[install] Initializing..."
chmod +x "$DEST_DIR/bin/hypernode" || true
(cd "$DEST_DIR" && bin/hypernode init)

echo "[install] Building and starting..."
(cd "$DEST_DIR" && bin/hypernode build && bin/hypernode up)

echo "[install] Done. Health: curl http://127.0.0.1:8020/api/hypernode/health"

