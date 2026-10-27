# plausible 0.0.x / 0.1.0 -> 0.2.0 (Emporium 0.5)

Existing installs move with the installed-app blueprint
(`docs/blueprints/migrate-installed-app-to-v0.5.md` in monostream/emporium). There is no in-place
upgrade path from 0.0.x: the database and ClickHouse workloads are replaced.

## Removed and renamed inputs

- No user inputs existed before (0.0.x had no `## @userSupplied` fields).
- New input `Registration` (`DISABLE_REGISTRATION`, default `"true"`: only the first user can register,
  as before).
- New generated secret inputs (section Security): `SecretKeyBase`, `TotpVaultKey` (install-only),
  `ClickhousePassword`.
- Values removed with the wrapper: everything under `plausible.*` (the IMIO plausible-analytics
  subchart values). The chart's own values are `app`, `database`, `mailer`, `ingress`, `resources`,
  `clickhouse`.

## Database

- Replaced: yes. 0.0.x bundled the Bitnami postgresql subchart (StatefulSet
  `<release>-postgresql`, PVC `data-<release>-postgresql-0`, 10Gi). 0.1.0 already used the
  annotation-based CloudNativePG cluster `<release>-postgres`.
- New: postgres integration named `postgres` (CloudNativePG cluster `<release>-postgres`, the same
  name 0.1.0 created; PostgreSQL 17, database and owner `plausible`, extension `citext`, 8Gi grow-only).
- Existing installs start with an empty database; data moves only through the blueprint (pg_dump of
  the old database, restore into the new cluster while Plausible is stopped).
- Delivery: `secretKeys: {DATABASE_URL: uri-sslmode-require}` copies the CloudNativePG
  `postgresql://...?sslmode=require` URL into `<app>-emporium-secrets` under `DATABASE_URL`. Plausible
  3.x parses the `postgresql://` scheme (the old wrapper's wait script only parsed `postgres://`; it is
  gone).
- TLS: verify-full. The CloudNativePG CA Secret (`CASecretName`, key `ca.crt`) is mounted and
  `DATABASE_CACERTFILE` points at it; Plausible then connects with `verify: :verify_peer`, which takes
  precedence over `sslmode=require`.

## Data volumes

- ClickHouse (analytics events): 0.0.x/0.1.0 ran the Bitnami clickhouse subchart with a
  volumeClaimTemplate PVC (`data-<release>-clickhouse-shard0-0`, 10Gi, data under `/bitnami/clickhouse`).
  0.2.0 runs `clickhouse/clickhouse-server` with the `events` storage integration (new claim
  `<release>-events`, 10Gi grow-only, mounted at `/var/lib/clickhouse`). Events are not carried over.
- Keep step before uninstalling 0.0.x/0.1.0: volumeClaimTemplate PVCs (`data-<release>-postgresql-0`,
  `data-<release>-clickhouse-shard0-0`) are not deleted by `helm uninstall`, so nothing needs
  annotating; do not delete them until the new install is verified.
- To keep the statistics, export each site in the old install (Site settings -> Imports & Exports ->
  Export data, CSV) and import the CSV files into the new install; this avoids copying ClickHouse
  data between image layouts.
- Plausible's own data directory (`/var/lib/plausible`: temporary files, geolocation database) is an
  emptyDir; it holds nothing to keep.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent). The ingress class comes from
the `IngressClassName` output.

## Secrets

- `<app>-emporium-secrets`: `SECRET_KEY_BASE`, `TOTP_VAULT_KEY` (32 characters, base64-encoded by the
  container at start), `CLICKHOUSE_PASSWORD`, `DATABASE_URL` (postgres `secretKeys`), and the SMTP
  password (`smtp.mail.password`).
- The old `plausible` Secret (built with `lookup`/`randAlphaNum`) is deleted on upgrade. Two-factor
  secrets stay readable only with the old vault key: to keep two-factor logins of migrated users,
  install the new app with `TotpVaultKey` set to the old raw key,
  `kubectl get secret plausible -o jsonpath='{.data.TOTP_VAULT_KEY}' | base64 -d | base64 -d`.
  Otherwise users re-enroll two-factor authentication. A new `SECRET_KEY_BASE` signs everyone out once.
- No plaintext secrets in values; lint reports no plaintext warnings.

## Behaviour changes

- Default access is `public`: visitors' browsers must load the tracking script (`/js/*`) and post
  events (`/api/event`) without a login, and Plausible has its own accounts. Those two paths stay open
  if an admin chooses `authenticated`. Under 0.0.x the ingress used whatever access the installer
  picked, with no skip paths, so tracking broke behind login.
- Mail: optional `mail` integration, Bamboo.Mua adapter, TLS mode from the port (465 implicit TLS,
  otherwise STARTTLS). 0.0.x forced implicit TLS (`ssl: true`) on the SMTP adapter, which failed on 587.
- The ClickHouse and database passwords no longer change on upgrade (0.0.x shadowed the stored value
  in its template, so every upgrade generated a new password).
- Plausible waits for ClickHouse (`/ping`) in an init container; probes use
  `/api/system/health/{live,ready}`.
- No `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations from the chart.
