# 0.1.0

Published on 19 October 2026

- PostgreSQL is provided by Emporium's native Postgres integration (CloudNativePG, PostgreSQL 17, citext) instead of the bundled Bitnami postgresql subchart. DATABASE_URL is assembled from the CloudNativePG app secret. Requires Emporium v0.5.0. Existing data in the bundled database is not migrated.
- Plausible connects to PostgreSQL over TLS and verifies the server certificate and hostname against the CloudNativePG CA (<release>-postgres-ca, via DATABASE_CACERTFILE)
- The ClickHouse password is kept across upgrades (it was regenerated on every upgrade)
- ClickHouse is always named plausible-clickhouse (fullnameOverride was misspelled, so CLICKHOUSE_DATABASE_URL only worked for releases named plausible)

# 0.0.9

Published on 7 October 2026

- plausible-analytics from 0.3.0 to 0.4.2

