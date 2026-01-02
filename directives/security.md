# Security & Operational Directives

- Secrets: Keep admin credentials in a local `.env` or `scripts/admin.env`. Do not commit.
- Least privilege: Use a dedicated MongoDB user (readWrite on app DB). Avoid root.
- Network: Restrict MongoDB to trusted hosts (bindIp, firewalls). Use TLS where possible.
- CORS: Restrict `NEXT_PUBLIC_CORS_ORIGINS` to known origins for production.
- Sessions: Prefer Secure cookies under HTTPS (`NEXT_PUBLIC_BASE_URL=https://...`).
- CI: Store secrets in GitHub Actions secrets (never in the repo). Use matrix to override `MONGO_URL`.
- Backups: Enable automated Mongo dumps in ops scripts (not included by default).
- Logs: Avoid printing secrets in verbose logs. Redact known keys.

