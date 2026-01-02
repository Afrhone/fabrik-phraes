#!/usr/bin/env bash
set -euo pipefail

# Seed admin user using existing project script

ENV_FILE="scripts/admin.env"
FORCE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file) ENV_FILE="$2"; shift 2;;
    --force) FORCE="--force"; shift;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Admin env file not found: $ENV_FILE" >&2
  exit 1
fi

AUTOMATED=1 node scripts/create-admin-user-direct.js --env-file "$ENV_FILE" $FORCE

