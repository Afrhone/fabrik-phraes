#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
OUT="$DIST_DIR/fabrik-bundle.tar.gz"

mkdir -p "$DIST_DIR"
echo "[fabrik] Bundling Fabrik project → $OUT"
tar -czf "$OUT" -C "$ROOT_DIR" .
echo "[fabrik] Done: $OUT"

