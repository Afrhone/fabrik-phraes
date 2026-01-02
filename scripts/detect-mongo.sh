#!/usr/bin/env bash
set -euo pipefail

# detect-mongo.sh host:port
# Returns 0 if TCP is reachable, 1 otherwise

hostport="${1:-mongo:27017}"
host="${hostport%%:*}"
port="${hostport##*:}"

timeout_secs=${TIMEOUT_SECS:-2}

if bash -c "</dev/tcp/${host}/${port}" >/dev/null 2>&1; then
  exit 0
fi

# Try with timeout using nc if available
if command -v nc >/dev/null 2>&1; then
  if nc -z -w ${timeout_secs} "$host" "$port" 2>/dev/null; then
    exit 0
  fi
fi

exit 1

