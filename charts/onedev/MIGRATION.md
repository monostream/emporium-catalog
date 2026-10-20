# onedev 0.0.x -> 0.1.0 (Emporium 0.5)

## Removed and renamed inputs

- `Username`, `Password`: kept (same keys, stored values carry over). `Password` is a secret input
  now (generated when empty); both only matter on the first start, so they are install-only.
- `StorageSize`: kept, install-only (StatefulSet volumeClaimTemplate), default 20Gi.
- `PersistenceStorageClass` -> `StorageClass` (`renamedFrom`, the stored value carries over).

## Database

- Default unchanged: OneDev's embedded database on the data volume.
- New optional `db` postgres integration (`required: false`, install toggle, PostgreSQL 17,
  database and owner `onedev`, 10Gi grow-only). Wired through OneDev's `hibernate_*` environment
  variables with the password by `secretKeyRef` from the CloudNativePG app Secret (the upstream
  `database.external` path would copy the password into its Secret from plain values).
  TLS: `sslmode=require` (encrypted, not verified: the JDBC driver has no CloudNativePG CA).
- No migration from the embedded database to PostgreSQL in the chart; OneDev's own backup/restore
  (Administration > Database Backup) moves data between databases.

## Data volumes

- OneDev data lives on the upstream StatefulSet's volumeClaimTemplate `data` (claim
  `data-<release>-onedev-0` or `data-<release>-0`), size `StorageSize`, class `StorageClass`.
  It is **not** a `storage` integration: the upstream chart (onedev 11.9.0) has no existingClaim
  option, so the uninstall keep/delete choice does not cover it and the claim stays after
  uninstall (Kubernetes keeps volumeClaimTemplate claims). TODO: fork or upstream an
  existingClaim option, then move it to a storage integration.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- Admin password: `<app>-emporium-secrets`, key `Password`, as `initial_password` (was plaintext
  in the values and copied into the upstream Secret).
- Postgres password: CloudNativePG app Secret by `secretKeyRef`.
- No plaintext secrets remain.

## Behaviour changes

- The chart sets no `emporium.build/auth-*` annotations; skip paths `/api/*`, `/*.git/*`,
  `/*/*.git/*` are `skipPaths` of the ingress integration (the old `regex(...)` form is gone).
- Upstream nginx cookie-affinity annotations and `service-upstream` are removed.
