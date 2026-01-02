#!/usr/bin/env bash
set -euo pipefail

# End‑to‑end bootstrap for a local/dev setup

ENV_FILE=".env"
DEFAULT_HP="mongo:27017"
FALLBACK_HP="127.0.0.1:27020"

echo "[fabrik] Step 1/3: Configure Mongo URL"
bash fabrik/scripts/configure-mongo.sh --env-file "$ENV_FILE" --default "$DEFAULT_HP" --fallback "$FALLBACK_HP"

echo "[fabrik] Step 2/3: Seed admin (if configured)"
if [[ -f scripts/admin.env ]]; then
  bash fabrik/scripts/seed-admin.sh --env-file scripts/admin.env --force || true
else
  echo "[fabrik] No scripts/admin.env found; skipping admin seed"
fi

echo "[fabrik] Step 3/3: Summary"
grep -E "^MONGO_URL=" "$ENV_FILE" || true
echo "Done. Next: node fabrik/cli/fabrik.mjs --interactive"

