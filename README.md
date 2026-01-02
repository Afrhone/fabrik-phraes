# Fabrik‑Phraes (Open Source)

Fabrik‑Phraes bundles a minimal Hypernode Gateway, Fabrik configs, and a CLI to run a local, gated node that integrates with a Factory/Hypergraph ecosystem. This folder is a self-contained, OSS-friendly app you can release independently.

Features
- Hypernode Gateway (FastAPI, port 8020) with health/resources/handshake
- Fabrik config store: roles, tribes, hypernode.yml, composer config
- CLI for init/build/up/down/status/keys/export
- Docker Compose to run the gateway
- MIT License; contribution and security notes

Quickstart
- Requirements: Docker + Docker Compose plugin, bash, curl
- Init: `bin/hypernode init`
- Build: `bin/hypernode build`
- Up: `bin/hypernode up` → visit `http://127.0.0.1:8020/api/hypernode/health`
- Export: `bin/hypernode export` (creates `dist/` bundle)

Install via curl (example)
```
# Recommended: run the installer script hosted at:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Afrhone/fabrik-phraes/main/open-source/fabrik-phraes/install.sh)"

# Or export a release URL first (CI can publish to GitHub Releases):
export FABRIK_PHRAES_URL="https://github.com/Afrhone/fabrik-phraes/releases/download/v0.1.0/fabrik-phraes.tar.gz"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Afrhone/fabrik-phraes/main/open-source/fabrik-phraes/install.sh)"
```

Directory
- `bin/` CLI and helpers
- `fabrik/` local settings (env/ and secrets/ created at runtime)
- `services/hypernode-gateway/` gateway container source
- `docker-compose.yml` compose for the gateway
- `install.sh` one‑liner installer for servers
- `Makefile` convenience targets

Security
- Place secrets in `fabrik/secrets/` (created on init)
- Set `HYPERNODE_SHARED_SECRET` in `.env` or via `bin/hypernode keys`
- For production, place gateway behind your auth/ingress and enable a VPN

License
- MIT
