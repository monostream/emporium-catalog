# porter 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

- No user inputs existed before. New generated secret inputs: `CookieSecret`, `DbEncryptionKey`,
  `TokenEncryptionKey` (stable across upgrades; never change `DbEncryptionKey` after install).

## Database

- Replaced: yes. Old: Bitnami `postgresql` subchart 10.16.2 (PostgreSQL 11, StatefulSet
  `<release>-postgresql`, user/password `porter`/`porter`, image `bitnami/postgresql:11.12.0`, which
  is no longer pullable). New: `db` integration, CloudNativePG cluster `<release>-db`, PostgreSQL 17,
  database and owner `porter`, 8Gi grow-only, no extensions.
- Existing installs start with an empty database. To keep data, dump the old database before
  uninstalling (`pg_dump -U porter porter` in the `<release>-postgresql-0` pod) and restore it into
  `<release>-db` with the installed-app blueprint (`docs/blueprints/migrate-installed-app-to-v0.5.md`).
  Data encrypted with the old default `dbEncryptionKey` (`__random_strong_encryption_key__`) can
  only be read with that key: set the `DbEncryptionKey` input to the old value when restoring old
  data (it is exactly 32 characters).
- TLS: `DB_FORCE_SSL=true` (sslmode require; Porter cannot load a CA for verify-full).

## Data volumes (before uninstalling 0.1.x)

- The only volume is the Bitnami claim `data-<release>-postgresql-0`. StatefulSet claims survive
  `helm uninstall` (Helm does not delete volumeClaimTemplate claims), so no keep step is needed;
  delete the claim by hand once the data is restored.

## Hostnames

No extra hosts. `server.url` follows the hostname.

## TLS secret

`porter-cert-tls` became the integration's `TLSSecretName` (zone dependent). The pod no longer
mounts the TLS Secret (the upstream chart mounted `porter-cert-tls` at `/etc/wss` whenever its
Ingress was enabled; TLS ends at the ingress).

## Secrets

Plaintext in the Helm values, because the upstream porter chart renders its own Secrets
(`<release>-porter-api-server-keys`, `<release>-porter-db-secret`) from plain values and has no
`existingSecret` option (spec D16, blueprint pattern D). Acknowledged lint warnings:

- `plaintext-secret-in-values` x3: `CookieSecret`, `DbEncryptionKey`, `TokenEncryptionKey`.
- `plaintext-secret-output`: postgres `Password` bound to `porter.server.postgres.password`.
- `lookup-offline`: the disabled Bitnami postgresql subchart vendored in the porter tgz calls
  `lookup`; it renders nothing.

## Behaviour changes

- The upstream Ingress is off; the wrapper's own Ingress uses `pathType: Prefix` and the
  integration's ingress class.
- CPU limit removed (was 200m request = limit).

## Known limitations

- Porter's public repository and chart are no longer maintained (last chart 0.190.0 / image
  v0.52.56, both 2024). The chart is kept per the catalog triage.
- `DB_PORT` is fixed to 5432 by the upstream template (matches CloudNativePG).
