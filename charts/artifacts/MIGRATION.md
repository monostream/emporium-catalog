# artifacts 0.0.x / 0.1.0 -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

- `ArtifactsPersistenceSize` -> `StorageSize` (byteSize, default 10Gi, grow-only; `renamedFrom`, value carried over).
- `ArtifactsPersistenceStorageClass` -> `StorageClass` (storageClass, install-only; `renamedFrom`).
- `EnablePublicRead`: unchanged key, now a visible boolean with default false.
- Deleted (0.0.x): `PostgresqlPassword`, `PostgresqlPersistenceSize`, `PostgresqlPersistenceStorageClass`.
  The postgres integration owns the database; its size is an install choice (grow-only).

## Database

- 0.0.x: SQLite on the package volume by default, or the bundled Bitnami postgresql subchart when a
  Postgres password was given. Replaced: yes. Existing installs start with an empty database.
  Artifacts treats the storage as the source of truth: the indexer rebuilds the package index from the
  volume. User repository credentials, proxy settings and permissions live only in the database; move them
  with the installed-app blueprint (`docs/blueprints/migrate-installed-app-to-v0.5.md`) or recreate them.
- 0.1.0 (annotation-based native Postgres): the integration is named `postgres`, so the CloudNativePG
  cluster keeps its name `<release>-postgres`; no data move.
- Integration `postgres`: PostgreSQL 17, database and owner `artifacts`, extension `uuid-ossp`, 8Gi grow-only.
- TLS: `sslmode=require` (encrypted, unverified; the DSN is copied into the per-app Secret as
  `DATABASE_DSN` from `uri-sslmode-require`).

## Data volumes

- The package volume is still the chart-managed claim `<fullname>` (default `artifacts`), so a chart
  upgrade keeps it. Before uninstalling a 0.0.x/0.1.0 release (installed-app blueprint), protect it:
  `kubectl -n <ns> annotate pvc <fullname> helm.sh/resource-policy=keep`, and reinstall with the same
  release name so the new release binds the same claim name.

## Hostnames

- The UI host is the integration's `Hostname`.
- Repository hosts are unchanged and still nested: `<repo>.docker.<host>`, `<repo>.npm.<host>`, ...
  (the Artifacts router only understands this layout). They are outside a zone's wildcard certificate
  (`*.<zone>` covers one label), so in `wildcard` TLS mode the CLI hosts get no valid certificate; in
  `perHost` mode they need a DNS-01 issuer that can issue wildcard names. Known limitation until
  Artifacts supports flat repository hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- Encryption and signing keys stay in the subchart's own Secret `<fullname>` (generated with `lookup`,
  `helm.sh/resource-policy: keep`). Artifacts needs base64 of exactly 32/64 bytes, which `generate:`
  cannot produce. Consequence: the chart uses `lookup`, so preview shows no manifest diff. Keep this
  Secret when moving an install, or stored credentials become unreadable.
- The database DSN is in `<app>-emporium-secrets` (`DATABASE_DSN`).
- No plaintext secrets in values.

## Behaviour changes

- Access default `public` (the app authenticates itself; CLI clients cannot pass an Emporium login).
- Image pull policy `IfNotPresent` (was `Always`).
- No `kubernetes.io/tls-acme` annotation from the chart.
