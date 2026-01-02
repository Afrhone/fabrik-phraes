Fabrik Hypernode — Release Guide
================================

Prepare
1) Ensure `fabrik/` directory contains updated CLI, runner, and docs.
2) Update `fabrik/out/config.fabrik.json` via CLI if needed:
   - `node fabrik/cli/fabrik.mjs --interactive`

Bundle
- Option A (script): `bash fabrik/scripts/bundle.sh`
- Option B (CLI): `node fabrik/cli/fabrik.mjs hypernode bundle`
- Output: `fabrik/dist/fabrik-bundle.tar.gz`

Repo publish
- Create a new repository (e.g., `fabrik-hypernode`).
- Add files from `fabrik/` (excluding project-specific modules).
- Include `README.md`, `.env.fabrik.example`, `hypernode/`, `docker/`, `cli/`, `scripts/`, `docs/`, `directives/`.
- Set up CI (optional): add `fabrik/ci/fabrik-ci.yml` or a release workflow.

Install & run (in new repo)
1) `cp fabrik/hypernode/.env.example fabrik/hypernode/.env`
2) `node fabrik/cli/fabrik.mjs hypernode init` (configure base URL and traits)
3) `node fabrik/cli/fabrik.mjs hypernode join` (requests token from Factory)
4) Run: `node fabrik/hypernode/runner.mjs` or `docker compose -f fabrik/hypernode/docker-compose.yml --env-file fabrik/hypernode/.env up -d`

Factory requirements
- Expose Factory `/api/fabrik/hypernode/handshake` publicly.
- If `HYPERNODE_REQUIRE_TOKEN=1`, set `HYPERNODE_TOKEN_SECRET` and restart Factory.

Support endpoints
- `GET /api/fabrik/hypernode/status` — list nodes and status.
- `GET /api/hypergraph/list-nodes` — verify `type=hypernode` entries.

