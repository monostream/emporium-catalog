# vaultwarden 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None removed. New input `SignupsAllowed` (default `true`, the previous behaviour).

## Database

- Default unchanged: SQLite (`/data/db.sqlite3`) on the data volume.
- New optional `db` postgres integration (`required: false`, install toggle, PostgreSQL 17,
  database and owner `vaultwarden`, 5Gi grow-only). The provider copies `uri-sslmode-require`
  into `<app>-emporium-secrets` as `DATABASE_URL`, which Vaultwarden reads by `secretKeyRef`.
  TLS: `sslmode=require` (encrypted, not verified; a CA path cannot be added to a copied source key).
- The toggle is install-time; there is no SQLite -> PostgreSQL migration in the chart.

## Data volumes

- `data` (storage integration, default 1Gi, grow-only), mounted at `/data`. Emporium 0.4 created
  the same claim through the old storage integration; existing installs are moved with the
  installed-app blueprint (`docs/blueprints/migrate-installed-app-to-v0.5.md`) by choosing the old
  claim as existing claim. The data volume stays in use with PostgreSQL (attachments, keys, icons).
- No Helm-managed claim to protect: under Emporium 0.4 `existingClaim` was always set, so the
  chart never rendered its own PVC and the upgrade does not delete anything.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent: `<release>-tls` in
perHost mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

- SMTP password: `<app>-emporium-secrets`, key `smtp.mail.password` (was plaintext in the values).
- PostgreSQL URL (when enabled): `<app>-emporium-secrets`, key `DATABASE_URL`.
- No plaintext secrets remain.

## Behaviour changes

- SMTP is optional (`mail` integration `required: false`).
- `SIGNUPS_ALLOWED` now carries the sign-up setting (it was set to the domain by mistake).
- Skip paths: `/api/*`, `/identity/*` (Bitwarden clients); `/#/*` dropped (fragments never reach the server).
- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations.
