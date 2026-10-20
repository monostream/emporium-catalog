# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- plausible from v3.0.1 to v3.2.1.
- PostgreSQL is provided by Emporium's postgres integration (CloudNativePG, PostgreSQL 17, citext). Existing installs start with an empty database; the data in the old bundled database is not migrated (see the installed-app migration blueprint). `DATABASE_URL` is copied into the per-app Secret (`uri-sslmode-require`) and Plausible verifies the server certificate against the CloudNativePG CA (`DATABASE_CACERTFILE`).
- The IMIO plausible-analytics wrapper and its Bitnami subcharts are gone: the chart now ships its own Plausible Deployment and a ClickHouse StatefulSet on the official `clickhouse/clickhouse-server:24.12.6.70-alpine` image with Plausible Community Edition's low-resource settings. Existing ClickHouse event data is not carried over.
- `SECRET_KEY_BASE`, `TOTP_VAULT_KEY` and the ClickHouse password are generated once at install in the per-app Secret instead of `lookup`/`randAlphaNum` (the ClickHouse and database passwords changed on every upgrade).
- New "Registration" input (closed, invite only, open).
- Mail is optional and uses the Bamboo.Mua adapter (TLS by port, password by Secret reference); the old SMTP adapter forced implicit TLS.
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; default access is public (tracking script and events must reach Plausible), `/js/*` and `/api/event` stay open when access is restricted.
- ClickHouse data lives on the `events` storage integration (10Gi default, grow-only).
- Default resources for Plausible (100m / 384Mi, 1Gi limit) and ClickHouse (100m / 512Mi, 2Gi limit) instead of none.

# 0.1.0

Published on 19 October 2026

- PostgreSQL is provided by Emporium's native Postgres integration (CloudNativePG, PostgreSQL 17, citext) instead of the bundled Bitnami postgresql subchart. DATABASE_URL is assembled from the CloudNativePG app secret. Requires Emporium v0.5.0. Existing data in the bundled database is not migrated.
- Plausible connects to PostgreSQL over TLS and verifies the server certificate and hostname against the CloudNativePG CA (<release>-postgres-ca, via DATABASE_CACERTFILE)
- The ClickHouse password is kept across upgrades (it was regenerated on every upgrade)
- ClickHouse is always named plausible-clickhouse (fullnameOverride was misspelled, so CLICKHOUSE_DATABASE_URL only worked for releases named plausible)

# 0.0.9

Published on 7 October 2026

- plausible-analytics from 0.3.0 to 0.4.2

