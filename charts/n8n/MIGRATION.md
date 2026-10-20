# n8n 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

| Old key | New key | Note |
|---|---|---|
| `StorageSize` | deleted | The `data` storage integration owns the volume size (default 8Gi, grow-only). |

## Database

- Default unchanged: SQLite (`/home/node/.n8n/database.sqlite`) on the data volume.
- New optional `db` postgres integration (`required: false`, install toggle, PostgreSQL 17, database
  and owner `n8n`, 5Gi grow-only). Host, port, database and user go into the app ConfigMap; the
  password is read by `secretKeyRef` from the CloudNativePG app Secret.
- TLS: verified (`DB_POSTGRESDB_SSL_CA` points at the mounted `CASecretName`, `rejectUnauthorized`).
- The toggle is install-time; there is no SQLite -> PostgreSQL migration in the chart. Existing
  installs keep SQLite unless they are reinstalled with the toggle on (and then start with an empty
  database; export/import workflows and credentials with the n8n CLI if needed).

## Data volume (keep it before uninstalling 0.4)

- 0.1.37 created the claim `<fullname>` (the release name, or `<release>-n8n`) through the
  upstream chart, **without** `helm.sh/resource-policy: keep`. Before uninstalling a 0.4 release,
  annotate it so it survives:
  `kubectl -n <ns> annotate pvc <fullname> helm.sh/resource-policy=keep`.
  Then move the instance with the installed-app blueprint
  (`docs/blueprints/migrate-installed-app-to-v0.5.md`) and choose that claim as the existing claim.
- Releases before 0.1.37 kept data in an `emptyDir` (persistence sat at a dead key); there is no
  volume to keep.
- The volume holds n8n's encryption key (`/home/node/.n8n/config`). Credentials stored in the
  database cannot be decrypted without it, so keep the volume even with PostgreSQL.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent: `<release>-tls` in
perHost mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

- PostgreSQL password (when enabled): by reference to the CloudNativePG app Secret.
- No plaintext secrets in values. The encryption key stays on the data volume (setting
  `N8N_ENCRYPTION_KEY` would break existing installs with a key mismatch).

## Behaviour changes

- Access default stays `authenticated`. New skip paths, so external callers reach triggers:
  `/webhook/*`, `/webhook-test/*`, `/webhook-waiting/*`, `/form/*`, `/form-test/*`,
  `/form-waiting/*`, `/mcp/*`. Protect production webhooks with the trigger node's own
  authentication.
- `WEBHOOK_URL`/`N8N_EDITOR_BASE_URL` use the public hostname (they defaulted to `localhost:5678`).
- n8n 2.43.8 (image pinned in the chart's values).
- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations.
