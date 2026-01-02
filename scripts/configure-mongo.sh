#!/usr/bin/env bash
set -euo pipefail

# Configure MONGO_URL coherently by probing connectivity.
# Usage:
#   fabrik/scripts/configure-mongo.sh --env-file .env --default mongo:27017 --fallback 127.0.0.1:27020

ENV_FILE=".env"
DEFAULT_HOSTPORT="mongo:27017"
FALLBACK_HOSTPORT="127.0.0.1:27020"
DB_NAME="factory"
AUTH_SOURCE="admin"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file) ENV_FILE="$2"; shift 2;;
    --default) DEFAULT_HOSTPORT="$2"; shift 2;;
    --fallback) FALLBACK_HOSTPORT="$2"; shift 2;;
    --db) DB_NAME="$2"; shift 2;;
    --auth-source) AUTH_SOURCE="$2"; shift 2;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

script_dir="$(cd "$(dirname "$0")" && pwd)"
detect="$script_dir/detect-mongo.sh"

echo "[fabrik] Probing Mongo endpoints..." >&2
if "$detect" "$DEFAULT_HOSTPORT"; then
  CHOSEN="$DEFAULT_HOSTPORT"
  echo "[fabrik] Using default: $CHOSEN" >&2
elif "$detect" "$FALLBACK_HOSTPORT"; then
  CHOSEN="$FALLBACK_HOSTPORT"
  echo "[fabrik] Using fallback: $CHOSEN" >&2
else
  # last‑ditch localhost default
  CHOSEN="127.0.0.1:27017"
  echo "[fabrik] Neither default nor fallback reachable; using soft default $CHOSEN" >&2
fi

proto_hostport() {
  local hp="$1"
  # Preserve user:pass@ if provided via existing env
  if [[ -n "${MONGO_CREDENTIALS:-}" ]]; then
    echo "mongodb://${MONGO_CREDENTIALS}@${hp}/${DB_NAME}?authSource=${AUTH_SOURCE}"
  else
    echo "mongodb://${hp}/${DB_NAME}?authSource=${AUTH_SOURCE}"
  fi
}

MONGO_URL_NEW="$(proto_hostport "$CHOSEN")"
echo "[fabrik] Resolved MONGO_URL=$MONGO_URL_NEW" >&2

# Update or append in ENV_FILE
touch "$ENV_FILE"
if grep -qE '^\s*MONGO_URL\s*=' "$ENV_FILE"; then
  sed -i.bak -E "s|^\s*MONGO_URL\s*=.*$|MONGO_URL=\"$MONGO_URL_NEW\"|" "$ENV_FILE"
else
  printf "\nMONGO_URL=\"%s\"\n" "$MONGO_URL_NEW" >> "$ENV_FILE"
fi

echo "[fabrik] Wrote MONGO_URL to $ENV_FILE" >&2

