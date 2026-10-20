# wastebin 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

| Old key | New key | Note |
|---|---|---|
| `StorageSize` | deleted | The `data` storage integration owns the volume size (default 1Gi, grow-only). |
| `Title` | `Title` | Unchanged, default `Wastebin`. |
| `Theme` | `Theme` | Now an enum; adds `rosepine`. Default `gruvbox`. |

New generated secret inputs: `SigningKey`, `PasswordSalt`.

## Database

No database change. SQLite stays at `/data/state.db` on the data volume. No PostgreSQL.

## Data volume (keep it before uninstalling 0.4)

0.1.x created `<release>-wastebin-data` (or `<release>-data` when the release name contains
`wastebin`) with `helm.sh/resource-policy: keep`, so a 0.4 uninstall leaves the claim behind.
0.2.0 under Emporium binds the `data` storage integration to `persistence.existingClaim` and does not
render its own PVC. Move installed instances with the installed-app blueprint
(`docs/blueprints/migrate-installed-app-to-v0.5.md`) and choose the old claim as the existing claim.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent: `<release>-tls` in perHost
mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

- `WASTEBIN_SIGNING_KEY` and `WASTEBIN_PASSWORD_SALT` live in `<app>-emporium-secrets`.
- No plaintext secrets in values.
- **Password salt and existing encrypted pastes:** 0.1.x ran with Wastebin's built-in salt
  `somesalt`. A migrated instance gets a freshly generated salt, which makes pastes that were
  encrypted with a password unreadable. If an instance has password-protected pastes that must stay
  readable, set the `PasswordSalt` input to `somesalt` during the migration.
- The signing key was random per pod start before; existing owner cookies become invalid once
  (they did on every restart already).

## Behaviour changes

- Image pinned to 3.9.0 (was `latest`).
- Access default stays `authenticated` (the whole app behind the Emporium login, as before).
- The chart no longer writes `emporium.build/auth-*`, `kubernetes.io/tls-acme` or
  `kubernetes.io/ingress.class` annotations; dropped `proxy-*-timeout` annotations (60s, the default).
- Read-only root filesystem, emptyDir at `/tmp` (`TMPDIR`), `Recreate` strategy.
