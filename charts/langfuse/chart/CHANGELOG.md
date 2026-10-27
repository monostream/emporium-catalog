# 0.1.2

Published on 27 October 2026

- langfuse from 4.68.0 to 4.70.1
- langfuse-worker from 4.68.0 to 4.70.1

# 0.1.1

Published on 23 October 2026

- langfuse (web and worker) from 4.67.0 to 4.68.0

# 0.1.0

- New chart: Langfuse 4.67.0 (official images `langfuse/langfuse` and `langfuse/langfuse-worker`, MIT core), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG), connection verified against the CloudNativePG CA; Redis (Valkey, persistent) through the `cache` redis integration; S3 storage (RustFS) through the `files` objectStorage integration.
- Single-node ClickHouse (official `clickhouse/clickhouse-server` image) with a volume sized through the `traces` storage integration.
- Single sign-on through Emporium (generic OpenID Connect, ES384 ID tokens); new accounts join the "Emporium" organization with a configurable role; optional block for new accounts.
- Bootstrap organization, project and administrator with generated password and project API keys, delivered by Secret reference.
- `/api/public/*` (SDK ingestion, OpenTelemetry, REST API) skips the Emporium login and authenticates with project API keys.
- Telemetry off; no enterprise-licensed features enabled.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, SSO login with a new Emporium user (account created in the "Emporium" organization), bootstrap administrator login, trace ingestion through the skipped `/api/public/*` path, uninstall without leftovers.
- Review fixes (re-verified on 0.5.0-rc.12): PostgreSQL TLS now `sslaccept=strict` (a wrong CA is rejected, verified on the live pod); only the key-authenticated `/api/public/*` routes skip the Emporium login, `/api/public/health` and `/ready` stay behind it; NetworkPolicy limits ClickHouse to the web and worker pods; `deps.json` points at `web.image.tag` and `worker.image.tag`.
