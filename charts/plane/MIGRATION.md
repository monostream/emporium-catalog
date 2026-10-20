# plane 0.1.x / 0.2.0 -> 0.3.0 (Emporium 0.5)

## Removed and renamed inputs

- None of the old chart's values were user inputs (no comment-DSL fields).
- New: `SecretKey`, `LiveServerSecretKey` (generated secrets in `<app>-emporium-secrets`),
  `EnableSignup` (install-only seed of Plane's "allow sign-ups" instance setting, default off).
- Values layout changed: one shared `resources`/`replicaCount` became per-component
  `api/worker/beat/migrator/web/space/admin/live.resources` and `*.replicaCount`. `redis:` and
  `minio:` (Bitnami subchart values) are gone; `redis.existingSecret/urlKey` and `objectStorage.*`
  take their place.

## Database

- Replaced: no for 0.2.0, yes for 0.1.x.
- 0.2.0 (W4, `emporium.build/postgres` annotation): the integration is named `postgres`, so the
  CloudNativePG cluster keeps its name `<release>-postgres` (PostgreSQL 17, database and owner
  `plane`, 8Gi grow-only). No data move.
- 0.1.x (catalog main): data lived in the bundled Bitnami `postgresql`; `DATABASE_URL` pointed at a
  non-existent service, so these installs did not work. Existing installs start with an empty
  database; if there is data to keep, move it with the installed-app blueprint
  (`docs/blueprints/migrate-installed-app-to-v0.5.md`: dump from the Bitnami pod, restore into
  `<release>-postgres` while the app is stopped).
- TLS: libpq default `sslmode=prefer` (CloudNativePG always serves TLS, so the connection is
  encrypted; Plane cannot load the CA for verify-full).

## Redis and uploads

- Redis: Bitnami `redis` subchart -> two redis integrations (Valkey, persistent, 1Gi each):
  `redis` (`<release>-redis`, Django cache and live server) and `queue` (`<release>-queue`, the
  Celery broker, `AMQP_URL`). They are separate because the API's `clear_cache` runs `FLUSHDB` on
  the cache at every start, which would wipe queued tasks.
  Nothing to carry over: queued tasks and cache rebuild themselves.
- Uploads: Bitnami `minio` subchart (`<release>-minio`, bucket `uploads`) -> `uploads` integration
  (RustFS StatefulSet `<release>-uploads`, bucket `uploads`, 10Gi). Existing attachments are not
  copied. To keep them, copy the bucket before uninstalling 0.x, for example with
  `mc mirror old/uploads new/uploads` (old: the MinIO root credentials from the `<release>-minio`
  Secret; new: `objectStorage.uploads.accessKey`/`secretKey` from `<app>-emporium-secrets`).

## Data volumes (before uninstalling 0.x)

- The old chart's volumes are the Bitnami MinIO claim (`<release>-minio`) and the Redis claim
  (`redis-data-<release>-redis-master-0`). Only MinIO holds user data. `helm uninstall` deletes
  the MinIO claim (it has no `helm.sh/resource-policy: keep`). Copy the bucket first (above), or
  set the bound PV to `Retain` before the uninstall:

  ```bash
  PV=$(kubectl -n <ns> get pvc <release>-minio -o jsonpath='{.spec.volumeName}')
  kubectl patch pv "$PV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
  ```

- The old `<release>` Secret with `secret-key` had `helm.sh/resource-policy: keep` and stays after
  the uninstall; delete it by hand once migrated. Sessions signed with the old key end (users log
  in again).

## Hostnames

No extra hosts. Plane's admin area is `https://<host>/god-mode`, public spaces `/spaces`,
uploads `/uploads` (presigned S3 URLs through the ingress).

## TLS secret

`plane-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- `SECRET_KEY` and `LIVE_SERVER_SECRET_KEY`: `<app>-emporium-secrets` (generated once, stable).
- Redis URLs: `<app>-emporium-secrets`, keys `REDIS_URL` (cache) and `QUEUE_URL` (Celery broker),
  copied by the integrations' `secretKeys`.
- S3 credentials: `<app>-emporium-secrets`, keys `objectStorage.uploads.accessKey` and
  `objectStorage.uploads.secretKey`.
- SMTP password: `<app>-emporium-secrets`, key `smtp.mail.password` (was plaintext in the values).
- Database: the CloudNativePG app Secret (`DATABASE_URL`, `PGUSER`, `PGPASSWORD`).
- No plaintext secrets in the values; no lint warnings.

## Behaviour changes

- The chart was broken on Plane v1.4.2 (start scripts removed from the v1 images, no Celery
  broker, no admin app, `/spaces` routed to the API). It now follows the upstream plane-ce layout.
- Access defaults to `admins`: the first person to finish `/god-mode` becomes the instance admin,
  so only Emporium admins reach the app until then. After an admin has completed `/god-mode`,
  relax the app's access to `authenticated` (or `public`) in the Emporium app settings so the team
  can sign in. `/api/v1/*` skips the login (API keys).
- SMTP settings seed Plane's instance configuration on first start only (Plane stores them in its
  database; later changes go through `/god-mode`).
- The ingress body limit follows `app.fileSizeLimit` (5 MiB uploads -> `proxy-body-size: 6m`).

## Known limitations

- The web and admin images run nginx as root (upstream images); no `runAsNonRoot` is set.
