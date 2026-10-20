# 0.2.0

Published on 20 October 2026

- The upstream uptrace chart is no longer a dependency: its Uptrace StatefulSet, ConfigMap, Service, ServiceAccount and Ingress are templates of this chart (same object names and selectors). The container start quotes the SMTP password as a YAML scalar at runtime, so passwords with YAML syntax neither break the config nor leak into its error.
- Requires Emporium v0.5.0 (`emporium.yaml`).
- uptrace from 2.0.2 to 2.0.3 (upstream chart 2.0.2); ClickHouse from 25.3 to 26.3.56.2.
- PostgreSQL is provided by Emporium's postgres integration `postgres` (CloudNativePG, PostgreSQL 17, cluster `<release>-postgres`) instead of the bundled Bitnami postgresql subchart of 0.0.x. Existing installs start with an empty database; the data in the old bundled database is not migrated (see the installed-app migration blueprint). The connection is encrypted; the server certificate is not verified (the upstream chart cannot mount the CloudNativePG CA).
- Redis cache through Emporium's redis integration (Valkey, cache mode), which Uptrace 2 uses for caching.
- The Uptrace configuration uses the Uptrace 2 format: the 1.x keys the chart wrote (`site.addr`, `auth.users`, `auth.oidc`, `projects`, `secret_key`) were ignored, so installs ran with the upstream defaults (admin@uptrace.local / admin, the placeholder service secret, `project1_secret` DSN token). Now the admin user comes from the new "Admin email" and "Admin password" inputs, and the service secret and project DSN tokens are generated at install.
- ClickHouse is this chart's own ClickHouseInstallation (Altinity operator, declared in `requiredCRDs`) with a generated password instead of the hardcoded `uptrace`, resources, and a working "ClickHouse disk size" input (the old input never reached the installation, which always got 10Gi); the volume names of the old installation are kept.
- Removed the OIDC sign-in: Uptrace 2 configures SSO in its UI per organization, not in the config file.
- Optional SMTP through the `mail` integration for alert and invitation emails.
- Ingress host, TLS secret, ingress class and annotations come from the `web` ingress integration; OTLP/HTTP ingestion (`/v1/*`) skips the Emporium login and authenticates with the project DSN.
- Default resources for Uptrace and ClickHouse instead of none.

# 0.1.0

Published on 19 October 2026

- PostgreSQL is provided by Emporium's native Postgres integration (CloudNativePG, PostgreSQL 17) instead of the bundled Bitnami postgresql subchart; the password comes from the CloudNativePG app secret. Requires Emporium v0.5.0. Existing data in the bundled database is not migrated.
- Uptrace connects to PostgreSQL over TLS (sslmode require semantics: encrypted, server certificate not verified, as the subchart cannot mount the CloudNativePG CA)
- UPTRACE_ADMIN_PASSWORD is set from the uptrace Secret (the config referenced it but it was never defined)
- The OpenTelemetry collector daemonset (an OpenTelemetryCollector custom resource that needs the OpenTelemetry operator) is disabled
