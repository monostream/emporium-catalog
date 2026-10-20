# supabase 1.0.x -> 2.0.0 (Emporium 0.5)

2.0.0 replaces the Bitnami `supabase` chart (5.3.6; deprecated, its images can no longer be pulled)
with the supabase-community chart (`supabase` 0.8.0, https://github.com/supabase-community/supabase-kubernetes).
Object names, Secrets, volumes and the database image all change: **existing installs cannot be
upgraded in place.** Install 2.0.0 as a new app and move the data (see Database).

## Removed and renamed inputs

| Old key | New key | Note |
|---|---|---|
| `StorageSize` | deleted | Files go to the `files` objectStorage integration (size chosen at install, grow-only). |
| `DatabaseSize` | deleted | The `db` storage integration owns the database volume (default 8Gi, grow-only). The old input had no effect before 1.0.55. |

New inputs: `SiteUrl`, `AdditionalRedirectUrls`, `DisableSignup` (section Authentication),
`OpenAiApiKey` (default `none`, assistant off). Generated (section Keys and passwords, install-only
where marked): `JwtSecret`*, `DbPassword`*, `DbName` (fixed `postgres`), `RealtimeSecretKeyBase`*,
`RealtimeDbEncKey`*, `MetaCryptoKey`*, `S3ProtocolKeyId`, `S3ProtocolSecret`, `DashboardUsername`,
`DashboardPassword`.

## Database

- Replaced: yes. Documented exception to the `postgres` integration: Supabase keeps its own
  `supabase/postgres` 17.6 database (about 50 extensions, `shared_preload_libraries`, service roles
  created at init as superuser; the CloudNativePG provider offers none of these).
- Old location: the Bitnami `supabase-postgres` StatefulSet volume. New: the `db` storage
  integration (data directory in the `postgres-data` subPath, the pgsodium config with its root key
  at the volume root).
- Data does not move automatically. Keep the old app until the new one is verified, then:
  1. Start the new app once so its services create the Supabase schemas.
  2. From the old database dump your own schemas (`public` and others) in full and the `auth` and
     `storage` schemas data-only (`pg_dump --data-only --schema=auth --schema=storage`).
  3. Restore into the new database (`kubectl exec` into the `*-supabase-db-0` pod, user
     `supabase_admin` or `postgres`, password in `<app>-emporium-secrets` key
     `SUPABASE_DB_PASSWORD`). Do not restore roles.
  4. Files: copy the objects of the old storage volume into the `supabase` bucket of the new
     object storage (path `stub/<bucket>/<object>`); bucket rows come with the `storage` schema.
- TLS to the database: none (in-namespace traffic, as upstream).

## Data volumes

`db`, `functions` and `snippets` are Emporium storage claims, so the uninstall dialog decides
whether they are kept. When reinstalling with kept claims, enter the old `DbPassword` (and
`JwtSecret`, to keep the API keys and sessions): a newly generated password does not match the
roles in the kept database. The old 1.0.x volumes are Helm-managed Bitnami claims; copy their data
as described above before uninstalling the old app.

## Hostnames

The second host `api.<host>` is gone: the APIs live on the app's own host under `/rest/v1`,
`/auth/v1`, `/storage/v1`, `/realtime/v1`, `/functions/v1`, `/graphql/v1`. Update your apps'
Supabase URL to `https://<host>`.

## TLS secret

`<release>-tls` (Studio) and the api host's secret became the integration's `TLSSecretName` (zone
dependent: `<release>-tls` in perHost mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

- All generated credentials live in `<app>-emporium-secrets` (keys `SUPABASE_*`), delivered by
  `secretKeyRef`. The SMTP password stays in the integration key `smtp.mail.password`; the object
  storage credentials in `objectStorage.files.*`.
- The anon and service_role keys change (new JWT secret): update your apps. Existing user sessions
  are invalidated. They are in Secret `supabase-keys` (keys `anonKey`, `serviceKey`) and shown in
  Studio. Helm creates that Secret without data (deleted with the release); the Job
  `<release>-supabase-keys-<revision>` (get/update on that Secret only) runs on every install and
  upgrade. It signs the keys once and never re-signs them: if the Secret holds a different JWT
  secret, the Job fails without writing. It copies the SMTP user and password (upstream reads both
  from one Secret) on every run; an init container keeps Auth waiting until the copy matches the
  smtp integration.
- `DbPassword` accepts only `A-Z a-z 0-9 . _ ~ -` (16+ characters): it goes into the services'
  connection URLs without encoding.
- No plaintext secrets in values (upstream's sample analytics tokens are blanked).

## Behaviour changes

- Studio is behind the Emporium login (default access `admins`); the API paths are skip paths.
- SMTP is optional; without it sign-ups are confirmed automatically.
- Not deployed: Logflare/Vector (log explorer), imgproxy (image transformations), MinIO.
- Upstream hard-codes `STORAGE_BACKEND=file` unless its own MinIO runs; the chart lists the
  variable again as `s3` and Kubernetes uses the last entry (the API server warns about the
  duplicate name). Re-check when bumping the dependency.
- One Supabase per namespace (fixed Secret name `supabase-keys`).
