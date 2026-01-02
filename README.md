# Fabrik Service Template

![CI](https://github.com/${GITHUB_REPOSITORY:-OWNER/REPO}/actions/workflows/fabrik-ci.yml/badge.svg)
![Handshake](https://github.com/${GITHUB_REPOSITORY:-OWNER/REPO}/actions/workflows/fabrik-handshake.yml/badge.svg)
![Release](https://github.com/${GITHUB_REPOSITORY:-OWNER/REPO}/actions/workflows/fabrik-release.yml/badge.svg)

A public-ready template for the Fabrik microservice with CI, automation workflows, Docker, and hooks to integrate with the Factory ecosystem.

## Features

- Express server with health and info endpoints
- Declarative integration manifest for Factory
- GitHub Actions: CI (install/lint/test/build), Release (release-please), Docker publish (GHCR), Webhook notify to Factory
- Dependabot for npm and GitHub Actions updates
- Dev scripts for local run and Factory registration

## Endpoints

- `GET /api/health` → `{ ok: true, name, version }`
- `GET /api/info` → basic metadata from `factory.integration.json`

## Environment

- `PORT` (default `4000`)
- `FACTORY_BASE_URL` (optional) — Factory root URL
- `FACTORY_TOKEN` (optional) — Bearer token for Factory integration
- `FACTORY_WEBHOOK_URL` (optional) — Webhook to notify Factory on push/releases

## Scripts

- `npm run dev` — start with nodemon (dev)
- `npm start` — start server
- `npm test` — run unit tests
- `npm run build` — build (noop for JS template)
- `npm run factory:register` — call Factory with service manifest

## Integration

- Manifest: `factory.integration.json`
- Registration script posts to `${FACTORY_BASE_URL}/api/factory/register` with Bearer `${FACTORY_TOKEN}`

## Docker

- `Dockerfile` provided; image publishes to GHCR via GitHub Actions on tag.

## Getting Started

```bash
cd fabrik
npm install
npm run dev
# open http://localhost:4000/api/health
```

## GitHub Setup

1) Create repo (public) and push this folder’s contents.
2) Set repository secrets as needed:
- `FACTORY_WEBHOOK_URL` (optional)
- `FACTORY_TOKEN` (optional)
- `GHCR_PAT` not required when using `GITHUB_TOKEN` for GHCR.

3) Enable Actions. Tag a release like `v0.1.0` to trigger Docker publish + release.

Note: Workflows live at repo root under `.github/workflows/*fabrik*.yml` and target this `fabrik` directory via `working-directory`.

## License

MIT
