# uptrace 0.0.x / 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

- `ClickHouseDiskSize`: kept (byteSize, grow-only, default 10Gi). It now reaches the ClickHouse
  volume; before it was a dead key and every install got 10Gi.
- New: `AdminEmail` (required), `AdminPassword` (required secret, letters, digits and
  `._~!@%^&*()+=-` only, because Uptrace substitutes it into its YAML config before parsing),
  `ClickHouseStorageClass` (install-only).
- New generated secrets (section Security): `ServiceSecret`, `ProjectToken1`, `ProjectToken2`,
  `ClickHousePassword`.

## Database

- PostgreSQL replaced: yes, for 0.0.x installs (Bitnami `postgresql` subchart, Secret
  `uptrace-postgresql`). New integration `postgres` (PostgreSQL 17, database and owner `uptrace`,
  8Gi grow-only, no extensions), CloudNativePG cluster `<release>-postgres`. 0.1.x installs (W4
  annotation) keep their cluster `<release>-postgres`. The data does not move with the upgrade;
  use the installed-app blueprint (`docs/blueprints/migrate-installed-app-to-v0.5.md`). Uptrace
  seeds the admin user, the "Emporium" organization and the projects again at start.
- TLS to PostgreSQL: encrypted, certificate not verified (`pg.tls.insecure_skip_verify: true`).
  The upstream chart has no way to mount the CloudNativePG CA for `ca_file`.
- Redis: new `redis` integration (Valkey, `mode: cache`, 128Mi, no volume).
- ClickHouse (no Emporium provider, D12): `clickhouse/clickhouse-server:26.3.56.2` run by the
  Altinity clickhouse-operator, which must be installed (`options.requiredCRDs`:
  `clickhouseinstallations.clickhouse.altinity.com`). The installation keeps the upstream names
  (`uptrace1`, volume templates `data-volume-template` and `log-volume-template`), so an in-place
  upgrade keeps the telemetry volumes. The ClickHouse user `uptrace` changes its password from
  `uptrace` to the generated `CLICKHOUSE_PASSWORD`.

## Data volumes

- ClickHouse volumes are created by the operator from the volume templates, and the operator (not
  Helm) deletes them when the ClickHouseInstallation is deleted. To keep telemetry through a 0.4
  uninstall, first set `spec.defaults.storageManagement.reclaimPolicy: Retain` on the
  ClickHouseInstallation `uptrace1`, wait for the operator to reconcile, then uninstall.
- The old Bitnami PostgreSQL PVC (`data-uptrace-postgresql-0`) is not deleted by Helm on
  uninstall (StatefulSet claim); keep it until the blueprint's restore is confirmed.

## Hostnames

No extra hosts.

## TLS secret

The hardcoded `uptrace-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- Per-app Secret `<app>-emporium-secrets`: `UPTRACE_SECRET`, `UPTRACE_ADMIN_PASSWORD`,
  `UPTRACE_TOKEN_PROJECT1`, `UPTRACE_TOKEN_PROJECT2`, `CLICKHOUSE_PASSWORD`, plus the redis and
  SMTP passwords. Uptrace reads all of them as environment variables (`${VAR}` in its config);
  ClickHouse reads its password through `secretKeyRef` in the installation.
- PostgreSQL password: from the CloudNativePG app Secret by `secretKeyRef`.
- The chart-owned `uptrace` Secret (`randAlphaNum` + `lookup`, `resource-policy: keep`) is gone.
  It stays in the namespace after the upgrade; delete it once the app runs. The DSN tokens
  change, so senders need the new DSN from the Uptrace project settings.
- No plaintext secrets remain.

## Behaviour changes

- The config is in the Uptrace 2 format. 0.0.x/0.1.x wrote 1.x keys that Uptrace 2 ignored, so
  installs ran with the upstream seed (admin@uptrace.local / admin) and placeholder secrets.
- OIDC sign-in through Emporium removed (Uptrace 2 configures SSO in its UI); the
  `oidcRedirectPaths` annotation is gone.
- Access: `authenticated` by default, with skip path `/v1/*` so OTLP/HTTP senders outside the
  cluster reach Uptrace with their DSN token. In-cluster senders can use the `uptrace` Service
  (HTTP 80, gRPC 4317).
- Optional SMTP (`mail` integration).
- No `kubernetes.io/tls-acme` annotation from the chart.

## Chart structure

- The upstream `uptrace` chart (2.0.2) is no longer a dependency; this chart renders the Uptrace StatefulSet, ConfigMap, Service, ServiceAccount and Ingress itself with the same names and selector labels, so they update in place. Values keep the `uptrace.uptrace.*` / `uptrace.ingress.*` layout.
- The SMTP password is turned into a single-quoted YAML scalar when the container starts (`SMTP_PASSWORD_YAML`); a password containing a line break is rejected at start.
