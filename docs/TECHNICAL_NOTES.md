Fabrik Hypernode — Technical Notes
==================================

Overview
- Hypernode is a lightweight companion that registers with Factory, receives a token, and sends periodic heartbeats to join the Hypergraph metacluster.
- Security: optional token enforcement via HMAC; admin-gated features via roles/tribes feature gates.

Components
- CLI `fabrik/cli/fabrik.mjs`:
  - `node fabrik/cli/fabrik.mjs --interactive` → generate `fabrik/out/config.fabrik.json`
  - `node fabrik/cli/fabrik.mjs hypernode init` → scaffold `.env`
  - `node fabrik/cli/fabrik.mjs hypernode join` → handshake and persist token to `fabrik/hypernode/state.json`
  - `node fabrik/cli/fabrik.mjs hypernode bundle` → tar.gz bundle in `fabrik/dist`
- Runner `fabrik/hypernode/runner.mjs` — registers and heartbeats; auto-handshakes if no token.
- API (Factory):
  - `POST /api/fabrik/hypernode/handshake` → returns `{ id, token }`
  - `POST /api/hypergraph/register-node` → upsert node with `type=hypernode` (optionally requires token)
  - `POST /api/hypergraph/heartbeat` → updates `lastSeenAt` (optionally requires token)
  - `GET /api/fabrik/hypernode/status` → list issued hypernode tokens/status

Token model
- Token = `HMAC_SHA256(secret, id:timestamp)` in base64url; header `x-hypernode-token` or `body.token`.
- Verify: compare HMAC; if `HYPERNODE_REQUIRE_TOKEN=1`, `register-node` and `heartbeat` require valid token.

Hypergraph join
- On `register-node`, Factory writes into `HypergraphNodes` with `type='hypernode'`, `attrs.traits`, `attrs.host` and timestamps.
- `heartbeat` updates `lastSeenAt` and optional metrics payload (load, mem, uptime).

Feature gates
- Feature flags derive from `fabrik/directives/roles-tribes-permissions.json` (or defaults):
  - `identity_tools`, `identity_batch`, `identity_home`, `identity_dashboard`
- Available to the frontend via `/api/fabrik/config` and `FabrikClientBootstrap` → `window.FEATURE_FLAGS`.

Env variables (Factory)
- `HYPERNODE_TOKEN_SECRET` — HMAC secret for hypernode tokens.
- `HYPERNODE_REQUIRE_TOKEN=1` — enforce token validation.

Data stores
- Mongo collections (if configured): `Hypernodes`, `HypergraphNodes`.
- File fallback: `data/hypernodes.json`, `data/hyperblocks.json`.

Bundle
- `fabrik/scripts/bundle.sh` or `node fabrik/cli/fabrik.mjs hypernode bundle` → `fabrik/dist/fabrik-bundle.tar.gz`.
  - Contents: `hypernode/`, `cli/`, `scripts/`, `docker/`, `README.md`, `.env.fabrik.example`, `docs/`, `directives/`.

