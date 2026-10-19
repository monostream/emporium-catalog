# 0.1.0

Published on 19 October 2026

- PostgreSQL is provided by Emporium's native Postgres integration (CloudNativePG, PostgreSQL 17) instead of the bundled Bitnami postgresql subchart; the password comes from the CloudNativePG app secret. Requires Emporium v0.5.0. Existing data in the bundled database is not migrated.
- Uptrace connects to PostgreSQL over TLS (sslmode require semantics: encrypted, server certificate not verified, as the subchart cannot mount the CloudNativePG CA)
- UPTRACE_ADMIN_PASSWORD is set from the uptrace Secret (the config referenced it but it was never defined)
- The OpenTelemetry collector daemonset (an OpenTelemetryCollector custom resource that needs the OpenTelemetry operator) is disabled
