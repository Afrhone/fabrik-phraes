# Mongo Connectivity Options

Option 1 — Update MONGO_URL to a resolvable address

- Preferred: `mongodb://mongo:27017/factory?authSource=admin` (service DNS or Compose service name)
- Alternative: `mongodb://127.0.0.1:27017/factory?authSource=admin` (local daemon)
- Fallback (Compose mapping): `mongodb://127.0.0.1:27020/factory?authSource=admin` (host‑published port 27020)

Automation

  bash fabrik/scripts/configure-mongo.sh \
    --env-file .env \
    --default mongo:27017 \
    --fallback 127.0.0.1:27020

This script probes the default and fallback endpoints, then writes a consistent `MONGO_URL`.

Option 2 — Add a hosts/DNS entry for "mongo"

If service DNS is unavailable, map `mongo` to a known IP:

  sudo bash fabrik/scripts/apply-hosts.sh 127.0.0.1

This appends an entry to `/etc/hosts` with a backup.

Coherent config

- Env files: `.env`, `.env.production`, or `fabrik/.env.fabrik.example`
- Docker: `fabrik/docker/docker-compose.yml`, `.env.docker`
- CI: `fabrik/ci/fabrik-ci.yml` exports `MONGO_URL` for tests/builds
- Scripts: read `MONGO_URL` and do not hardcode endpoints

Verification

  node -e "const net=require('net');const s=net.connect(27017,'mongo',()=>{console.log('ok');s.end();});s.on('error',e=>{console.error('fail',e.message)})"

