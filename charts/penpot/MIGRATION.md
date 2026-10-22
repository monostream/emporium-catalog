# penpot 1.0.x / 1.1.x -> 1.2.0 (Emporium 0.5)

## Removed and renamed inputs

- `APISecretKey`: kept under the same key, now `type: secret` with a generated default, delivered by
  reference (`<app>-emporium-secrets`, key `PENPOT_SECRET_KEY`). An existing value carries over; a new
  value signs everyone out.
- `PostgresPassword` (1.0.x): deleted, the postgres provider owns the password (already gone in 1.1.0).
- New: `Registration` (default on) and `PasswordLogin` (default on), both feed `PENPOT_FLAGS`.
- Chart values removed (never set by Emporium): `config.providers.{github,gitlab,google,ldap}`,
  `config.assets.*`, `persistence.*`, `smtp.*`, `global.redisEnabled`, `redis.*`, the plaintext
  `config.apiSecretKey` default.

## Database

- Replaced: yes. 1.0.x ran a Bitnami postgresql subchart (`<release>-postgresql`); 1.2.0 uses the
  `postgres` integration (CloudNativePG cluster `<release>-postgres`, PostgreSQL 17, database and owner
  `penpot`, extension `uuid-ossp`, 8Gi grow-only). The integration is named `postgres`, not `db`, so an
  install of the annotation-based 1.1.0 keeps its cluster name.
- Data: existing installs start with an empty database. Move it with the installed-app blueprint
  (`docs/blueprints/migrate-installed-app-to-v0.5.md`: stop the backend, `pg_dump` the old database,
  restore into `<release>-postgres`).
- TLS: verified (`sslmode=verify-full`, `sslrootcert` = the CloudNativePG CA from `CASecretName`,
  mounted at `/etc/penpot/postgres-ca/ca.crt`); the host is the `-rw.<ns>.svc` name in the certificate.

## Redis

- Bitnami redis subchart (`<release>-redis-*`, no auth) replaced by the `redis` integration (Valkey 8.1,
  `mode: cache`, 256Mi, no volume). Penpot uses Redis as message bus and worker dispatch queue only;
  tasks are stored in Postgres and rescheduled when a queue entry is lost, so nothing needs migrating.
- The connection URI (with password) is copied into the per-app Secret as `PENPOT_REDIS_URI`
  (`secretKeys`) and read by `secretKeyRef` in the backend and exporter.

## Object storage and data volumes

- Assets (images, fonts, file media, thumbnails) moved from the filesystem backend on the chart's PVC
  (`<fullname>`, usually `penpot`, 50Gi, mounted at `/opt/data`, assets under `/opt/data/assets`) to the
  `assets` objectStorage integration (RustFS, bucket `penpot`, 20Gi, `PENPOT_OBJECTS_STORAGE_BACKEND=s3`).
- **Keep the old volume before upgrading or uninstalling 0.4**: 1.2.0 no longer renders that PVC, so
  Helm deletes it on the upgrade. Annotate it first:
  `kubectl -n <ns> annotate pvc <fullname> helm.sh/resource-policy=keep`.
- Copy the assets into the bucket after the new install is up and before users upload (S27 blueprint
  "restore" step): mount the old PVC in a one-off pod and mirror `/opt/data/assets/` to
  `s3://penpot/` at the integration's `Endpoint`, using the access and secret keys from
  `<app>-emporium-secrets` (`objectStorage.assets.accessKey` / `.secretKey`). The object keys are the
  same relative paths in both backends.
- No filesystem fallback: `config.objectStorage.endpoint` and `existingSecret` are required.
- The frontend's nginx follows the backend's presigned redirects with its own resolver (no search
  domains); the chart appends `clusterDomain` (`cluster.local`) to a `<svc>.<ns>.svc` endpoint.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- `<app>-emporium-secrets`: `PENPOT_SECRET_KEY` (input), `PENPOT_REDIS_URI` (redis `secretKeys`),
  the object storage keys, the OIDC client secret and the SMTP password (provider keys).
- Postgres password: read from the CloudNativePG app Secret by `secretKeyRef`.
- The plaintext `penpot-secret` Secret (SMTP username and password) is gone. No plaintext secrets remain.

## Behaviour changes

- SMTP is optional (`mail`, `required: false`); without it `disable-email-verification` is set.
- OIDC: `enable-login-with-oidc` always; `enable-oidc-registration` follows `Registration`.
- Frontend: the image's own nginx template (port 8080, `PENPOT_BACKEND_URI`/`PENPOT_EXPORTER_URI`)
  replaces the chart's nginx.conf ConfigMap, which listened on port 80 and broke with the non-root
  2.x image.
- Exporter: `PENPOT_PUBLIC_URI` is the internal frontend Service, so exports work behind
  `authenticated` access; it no longer receives database or SMTP settings.
- Ingress: `nginx.ingress.kubernetes.io/proxy-body-size: 350m` (Penpot's upload limit); no
  `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations from the chart.
- Backend, frontend and exporter scale independently (1-5 replicas); the required pod affinity that
  pinned everything to one node (for the RWO volume) is gone.
