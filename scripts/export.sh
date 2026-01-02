#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
DIST="$ROOT_DIR/dist"
TS=$(date +%Y%m%d-%H%M%S)
OUT="$DIST/fabrik-phraes-$TS.tar.gz"

mkdir -p "$DIST"
tar -czf "$OUT" -C "$ROOT_DIR" fabrik services docker-compose.yml bin scripts README.md LICENSE || {
  echo "Tar failed" >&2; exit 1; }
echo "Bundle created: $OUT"

