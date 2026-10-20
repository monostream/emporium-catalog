# nextcloud 0.0.x / 0.1.0 -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

- `StorageSize`: deleted. The data volume is the `data` storage integration (size or an existing
  claim chosen at install, grow-only).
- New `AdminUsername` (required) and `AdminPassword` (generated when empty): secret inputs delivered
  by reference (`<app>-emporium-secrets`, keys `AdminUsername`, `AdminPassword`). They replace the
  chart-generated `nextcloud-admin-credentials` Secret (user `admin`, random password). Nextcloud
  only reads them when it installs itself on an empty volume; an existing install keeps its users.

## Database

- Replaced: no change of provider for 0.1.0 installs. Integration name `postgres` (CloudNativePG
  cluster `<release>-postgres`, PostgreSQL 17, database and owner `nextcloud`, 8Gi grow-only, no
  extensions), the name the 0.1.0 `emporium.build/postgres` annotation (W1 provider) created.
  Credentials by `secretKeyRef` from the CloudNativePG app Secret (`externalDatabase.existingSecret`).
- TLS: `PGSSLMODE=require` (encrypted, CA not verified). Nextcloud's `pgsql_ssl` setting is not
  used: with only `mode` set it writes empty `sslrootcert=`/`sslcert=`/... entries into the PDO
  DSN, which libpq misparses.
- Nextcloud persists the database settings (type, host, user, password) in `config/config.php` on
  the data volume at install time and ignores the environment afterwards:
  - 0.0.x installs ran on the internal SQLite database (the bundled Bitnami PostgreSQL was never
    used). Reusing their volume keeps SQLite; the `<release>-postgres` cluster stays empty. Convert
    with `occ db:convert-type --all-apps pgsql <user> <host> <db>` (password from the
    CloudNativePG app Secret) while the app is otherwise idle, if wanted.
  - 0.1.0 installs: the data is in `<release>-postgres`. Move it with the installed-app blueprint
    (`docs/blueprints/migrate-installed-app-to-v0.5.md`). If the destination cluster has a new
    password, update `dbpassword` (and `dbhost` if it changed) in `config/config.php` before
    starting the app.
- Existing installs start with an empty database (for a 0.1.0 install moved without the
  blueprint's restore step).

## Redis

The bundled Bitnami Redis (`<release>-redis-master` plus three replicas with 8Gi claims each) is
replaced by the `redis` integration (`<release>-redis`, Valkey, persistent, `noeviction`). Redis
holds only locks and cache entries; nothing needs to move. The old `<release>-redis-*` claims and
the `nextcloud-redis` Secret (`helm.sh/resource-policy: keep`) stay behind after the 0.4 uninstall
and can be deleted.

## Data volumes

- `data` (storage integration, default 20Gi, grow-only), mounted at `/var/www/html` (config,
  apps, user files under `data/`). 0.0.x/0.1.0 used the chart-created claim `<fullname>-nextcloud`,
  where `<fullname>` is the release name when it contains `nextcloud` and `<release>-nextcloud`
  otherwise (check with `kubectl -n <ns> get pvc`). Select it as the existing claim when migrating.
- The upstream nextcloud chart renders `helm.sh/resource-policy: keep` on that claim unconditionally
  (every version since 5.x), so the stored manifest already protects it from both upgrade and
  uninstall. **Check the stored manifest first:**

  ```bash
  helm -n <ns> get manifest <release> | grep -B2 -A12 'kind: PersistentVolumeClaim'   # resource-policy: keep?
  ```

- **Why a live annotation is not enough:** `kubectl annotate` on the claim protects a
  `helm upgrade`, but `helm uninstall` decides from the manifest stored in the release. The 0.5
  path for an installed 0.4 app is uninstall + reinstall (installed-app blueprint;
  `updateApp` refuses `NEEDS_MIGRATION` apps), so the keep annotation has to be in the stored
  manifest.
- **If it is missing** (it should not be): back the data up, set the bound PV to `Retain`, let the
  uninstall delete the claim, then clear the PV's `claimRef` and bind a new claim with the same name
  to it with `spec.volumeName`:

  ```bash
  PVC=<fullname>-nextcloud
  PV=$(kubectl -n <ns> get pvc "$PVC" -o jsonpath='{.spec.volumeName}')
  kubectl patch pv "$PV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
  # after the uninstall:
  kubectl patch pv "$PV" --type json -p '[{"op":"remove","path":"/spec/claimRef"}]'
  # create the claim again with spec.volumeName: $PV (same size/access mode/storageClassName), then
  # choose it as the existing claim of the data integration
  ```

## Hostnames

No extra hosts. `nextcloud.host` (trusted domain) and `OVERWRITECLIURL` follow the hostname.
Nextcloud also stores `overwrite.cli.url` and `trusted_domains` in `config.php`; after a hostname
change edit them there.

## TLS secret

`nextcloud-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- Admin username/password: `<app>-emporium-secrets`, keys `AdminUsername`, `AdminPassword`
  (were the chart's `nextcloud-admin-credentials` Secret with Helm-random values).
- Database: CloudNativePG app Secret, by reference.
- Redis password: `<app>-emporium-secrets`, key `redis.redis.password`, by reference
  (`externalRedis.existingSecret`).
- SMTP password: `<app>-emporium-secrets`, key `smtp.mail.password`, as `SMTP_PASSWORD` by
  `secretKeyRef`.
- No plaintext secrets in the values.

## Behaviour changes

- Access defaults to authenticated. `skipPaths`: `/remote.php/*`, `/ocs/*`, `/status.php`,
  `/index.php/login/v2*`, `/login/v2*`, `/public.php/*`, `/s/*`, `/index.php/s/*`,
  `/.well-known/*` (sync clients, login flow v2, public shares, DAV discovery). Choose access
  public if external users must reach other paths.
- SMTP is new and optional. `SMTP_SECURE` is `ssl` on port 465 and empty otherwise (STARTTLS when
  offered). Values set through the environment override the admin settings in the UI.
- Cron sidecar on (Nextcloud switches background jobs to "Cron" on the first run).
- Startup probe (up to 10 minutes) for the first-start installation.

## Known limitations

- Unverified on a cluster yet (coordinator smoke install pending).
- The upstream chart still vendors the Bitnami postgresql/mariadb/redis subcharts (disabled); lint
  reports their `lookup` calls (`lookup-offline` warnings), which never render.
