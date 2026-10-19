# vaultwarden 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None removed. New input `SignupsAllowed` (default `true`, the previous behaviour).

## Database

Not replaced. Vaultwarden keeps its SQLite database on the data volume.

## Data volumes

- `data` (storage integration, default 1Gi, grow-only), mounted at `/data`. Emporium 0.4 created
  the same claim through the old storage integration; existing installs are moved with the
  installed-app blueprint (`docs/blueprints/migrate-installed-app-to-v0.5.md`).

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent: `<release>-tls` in
perHost mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

- SMTP password: `<app>-emporium-secrets`, key `smtp.mail.password` (was plaintext in the values).
- No plaintext secrets remain.

## Behaviour changes

- SMTP is optional (`mail` integration `required: false`).
- `SIGNUPS_ALLOWED` now carries the sign-up setting (it was set to the domain by mistake).
- Skip paths: `/api/*`, `/identity/*` (Bitwarden clients); `/#/*` dropped (fragments never reach the server).
- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations.
