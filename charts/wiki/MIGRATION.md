# wiki 0.0.x / 0.1.0 -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None (the chart had no inputs).

## Database

- 0.0.x: the PostgreSQL StatefulSet bundled in the Wiki.js chart (`<release>-postgresql`, Helm-managed
  claim `<release>-postgresql`; with Wiki.js chart 2.x the Bitnami claim `data-<release>-postgresql-0`).
  Replaced: yes. Existing installs start with an empty database. Wiki.js 2 keeps pages, users, settings
  and uploaded assets in the database, so move it with the installed-app blueprint
  (`docs/blueprints/migrate-installed-app-to-v0.5.md`): `pg_dump` the `wiki` database from the old pod
  before uninstalling (the Helm-managed claim is deleted by `helm uninstall` unless you first run
  `kubectl -n <ns> annotate pvc <release>-postgresql helm.sh/resource-policy=keep`).
- 0.1.0 (annotation-based native Postgres): the integration is named `postgres`, so the CloudNativePG
  cluster keeps its name `<release>-postgres`; no data move.
- Integration `postgres`: PostgreSQL 17, database and owner `wiki`, no extensions, 8Gi grow-only.
- TLS: verify-full. `DB_SSL=true` and the CloudNativePG CA (`CASecretName`, key `ca.crt`) mounted and
  trusted through `NODE_EXTRA_CA_CERTS`; `Host` is the `-rw.<ns>.svc` name in the server certificate.

## Data volumes

No application volume (Wiki.js stores everything in PostgreSQL).

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- Database password: read from the CloudNativePG app Secret by `secretKeyRef`.
- No plaintext secrets.

## Behaviour changes

- The image is pinned (`requarks/wiki:2.5.316`) instead of the floating `2` tag.
- Access default `authenticated` (Emporium login in front of Wiki.js); choose `public` at install for a public wiki.
- No `kubernetes.io/tls-acme` annotation from the chart.
