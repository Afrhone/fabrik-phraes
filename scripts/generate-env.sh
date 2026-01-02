#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
FABRIK_DIR="$ROOT_DIR/fabrik"
mkdir -p "$FABRIK_DIR/env"

read -rp "Environment (dev/stage/prod) [dev]: " ENV
ENV=${ENV:-dev}
read -rp "Node name [fabrik-phraes-local]: " NODE
NODE=${NODE:-fabrik-phraes-local}

cat > "$FABRIK_DIR/env/.env.$ENV" <<ENV
NODE_ENV=$ENV
HYPERNODE_SHARED_SECRET=${HYPERNODE_SHARED_SECRET:-change-me}
HYPERNODE_NAME=$NODE
ENV
echo "Wrote $FABRIK_DIR/env/.env.$ENV"

