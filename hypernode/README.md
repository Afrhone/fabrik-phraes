Fabrik Hypernode — Open Source Join Node
========================================

Purpose
- A minimal, open-source “hypernode” that auto-configures, registers itself with the Factory app, and sends heartbeats to stay visible in the Hypergraph.
- Designed for one-command onboarding in dev or community deployments.

What it does
- Generates a deterministic node ID (hn:sha256) from a seed + host meta unless `HYPERNODE_ID` is provided.
- Calls Factory API `POST /api/hypergraph/register-node` to join.
- Periodically calls `POST /api/hypergraph/heartbeat` with lightweight metrics.

Prereqs
- A running Factory app (local or remote). Set `FACTORY_BASE_URL`.
- Optional MongoDB in Factory (the API auto-falls back to file mode if not set).

Quick start (local host)
1) Copy env and edit as needed:
   cp fabrik/hypernode/.env.example fabrik/hypernode/.env
2) Initialize and join (Node 18+):
   node fabrik/cli/fabrik.mjs hypernode init
   node fabrik/cli/fabrik.mjs hypernode join
   # (writes state.json with token); if Factory requires token and you skip join, runner will auto-handshake
3) Run the runner:
   node fabrik/hypernode/runner.mjs

Docker
   docker compose -f fabrik/hypernode/docker-compose.yml --env-file fabrik/hypernode/.env up -d

Key env vars
- `FACTORY_BASE_URL`: Base of Factory app, e.g. http://localhost:3101
- `HYPERNODE_NAME`: Display name. Default: fabrik-hypernode
- `HYPERNODE_SEED`: Seed string for deterministic ID (optional)
- `HYPERNODE_ID`: If set, skip generation and use this ID
- `HYPERNODE_TOKEN`: Optional token (Factory may require it). If empty, the runner will handshake to fetch one.
- `HYPERNODE_TRAITS`: JSON string of traits, e.g. {"region":"eu","cap":"viz"}
- `HEARTBEAT_SECONDS`: Interval for heartbeat (default 30)

API endpoints used
- Register: `POST /api/hypergraph/register-node` with { id?, name?, traits?, host? }
- Heartbeat: `POST /api/hypergraph/heartbeat` with { id, metrics? }

Notes
- No credentials are required for local dev. For production, set `HYPERNODE_REQUIRE_TOKEN=1` on Factory and use handshake.
- Handshake issues tokens at `POST /api/fabrik/hypernode/handshake`. Runner includes `x-hypernode-token` automatically when present in state or env.
- This package is self-contained and does not require building the Next.js app.
