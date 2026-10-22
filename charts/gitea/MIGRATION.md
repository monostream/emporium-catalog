# gitea 0.0.x / 0.1.0 -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

- `Username`, `Password` (local admin): kept under the same keys, now `type: secret` delivered by
  reference (`<app>-emporium-secrets`, keys `username` and `password`). The password is generated
  when left empty. `Username` is a secret input only because the Gitea chart reads both values from
  one Secret (`gitea.admin.existingSecret`); the field is blank after install.
- No input was removed.

## Admins

- Role-based admin sync is **off**: the `emporium` oauth source sets `groupClaimName: ""` and
  `adminGroup: ""` (empty, so `update-oauth` clears the "authentik Admins" mapping of 0.0.x/0.1.0 on
  upgrade). Gitea's `adminGroup` also demotes every user without the group, and the last admin
  cannot be demoted; same choice as forgejo 0.2.0.
- The scope `roles` is requested, ready for a grant-only mapping.
- Granting admin: log in as the local admin (`Username`/`Password` above), then Site
  administration > User accounts > edit the user > "Is administrator". OIDC users are
  auto-registered on first Logto login as regular users.

## Database

- Integration name `postgres` (CloudNativePG cluster `<release>-postgres`, PostgreSQL 17, database
  and owner `gitea`, 10Gi grow-only, no extensions), password by `secretKeyRef` from the
  CloudNativePG app Secret (`GITEA__database__PASSWD`). TLS: `SSL_MODE=require` (Gitea cannot load
  the CloudNativePG CA for verify-full).
- Per old version:
  - 0.1.0 (W4, `feat/native-postgres`, staging and emporium-dev only): `emporium.build/postgres`
    annotation; W1's provider named the cluster `<release>-postgres`. The S8 provider keeps that name
    for an integration called `postgres`, so a 0.1.0 install keeps its database. That is why the
    integration is not called `db`.
  - 0.0.37 and older (catalog main): data in the bundled Bitnami `postgresql-ha` subchart (3
    PostgreSQL pods plus pgpool). Existing installs start with an empty database; move the data with
    the installed-app blueprint (`docs/blueprints/migrate-installed-app-to-v0.5.md`: dump from the
    postgresql-ha primary, restore into `<release>-postgres` while the app is on hold).

## Redis

- New integration `redis` (Valkey StatefulSet `<release>-redis`, mode `persistent`, 1Gi, maxmemory
  256Mi, 512Mi in the medium profile) for `[cache]`, `[session]` and `[queue]`. The URL
  (`redis://:<password>@<host>:6379/0`) is copied into `<app>-emporium-secrets` under
  `gitea-redis-url` (`secretKeys`) and injected as `GITEA__cache__HOST`,
  `GITEA__session__PROVIDER_CONFIG` and `GITEA__queue__CONN_STR`.
- 0.0.x/0.1.0 ran the Bitnami `valkey-cluster` subchart (3 pods, one PVC each). It held
  only cache, sessions and queued jobs: nothing to migrate, but users log in again and jobs queued at
  the time of the uninstall are lost. Its PVCs are left behind by the uninstall; delete them after
  the migration.

## Data volumes

- `data` (storage integration, default 30Gi, grow-only), mounted at `/data` (repositories, LFS,
  attachments, Bleve index). 0.0.x/0.1.0 used the chart-managed claim `gitea-shared-storage`;
  select it as the existing claim when migrating.
- The upstream chart renders `helm.sh/resource-policy: keep` on `gitea-shared-storage` by default
  (`persistence.annotations` in Gitea chart 12.x), so the stored manifest normally already
  protects it from both upgrade and uninstall. **Check the stored manifest first:**

  ```bash
  helm -n <ns> get manifest <release> | grep -A6 'kind: PersistentVolumeClaim'   # resource-policy: keep?
  ```

  Only if it is missing:
- **Why a live annotation is not enough:** `kubectl annotate` on the claim protects a
  `helm upgrade`, but `helm uninstall` decides from the manifest stored in the release, which has no
  keep annotation. The 0.5 path for an installed 0.4 app is uninstall + reinstall (installed-app
  blueprint, `docs/blueprints/migrate-installed-app-to-v0.5.md`; `updateApp` refuses
  `NEEDS_MIGRATION` apps), so the keep annotation has to be in the stored manifest first.
- **Before uninstalling (preferred):** upgrade the release once more with the **old** chart version
  and the annotation in the values (the old chart passes `gitea.persistence.annotations` through),
  then check the stored manifest:

  ```bash
  helm -n <ns> upgrade <release> <catalog-repo>/gitea --version <installed 0.0.x/0.1.0 version> --reuse-values \
    --set-string 'gitea.persistence.annotations.helm\.sh/resource-policy=keep'
  helm -n <ns> get manifest <release> | grep -A6 'kind: PersistentVolumeClaim'   # must show resource-policy: keep
  ```

- **If that upgrade is not possible** (old chart version unavailable, release broken): back the
  data up, then take the volume out of Helm's hands before uninstalling: set the bound PV to
  `Retain`, let the uninstall delete the claim, then clear the PV's `claimRef` and bind a new claim
  named `gitea-shared-storage` to it with `spec.volumeName`:

  ```bash
  PV=$(kubectl -n <ns> get pvc gitea-shared-storage -o jsonpath='{.spec.volumeName}')
  kubectl patch pv "$PV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
  # after the uninstall:
  kubectl patch pv "$PV" --type json -p '[{"op":"remove","path":"/spec/claimRef"}]'
  # create PVC gitea-shared-storage with spec.volumeName: $PV (same size/access mode/storageClassName), then
  # choose it as the existing claim of the data integration
  ```

- If neither is possible, the claim does not survive the uninstall: migrating this install to 0.5
  is unsupported without losing the volume (Emporium 0.5 cannot upgrade a 0.4 app in place).

## Hostnames

No extra hosts. `server.ROOT_URL` is set from the hostname.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- Local admin username/password: `<app>-emporium-secrets`, keys `username`, `password`
  (were plaintext values).
- OIDC client secret: `<app>-emporium-secrets`, key `oidc.sso.clientSecret`, as the env variable
  `OIDC_CLIENT_SECRET` of the configure-gitea init container (was plaintext in the values).
- Redis URL: `<app>-emporium-secrets`, key `gitea-redis-url` (copied by the redis provider).
- SMTP password (optional `mail` integration): `<app>-emporium-secrets`, key `smtp.mail.password`,
  as `GITEA__mailer__PASSWD`.
- Nothing is delivered as plaintext through values; no `plaintext-secret-*` lint warnings.

## Behaviour changes

- Gitea 1.27.0 -> 28.2.0 (Gitea's new version scheme; 28.0 has breaking changes for Git network
  egress settings and adds `RUN_RETENTION_DAYS` for Actions runs; read the upstream release notes
  before upgrading a busy instance). The database schema is migrated by Gitea on first start.
- The chart sets no `emporium.build/auth-*` annotations and no `kubernetes.io/tls-acme`. Skip paths:
  `/api/*` and `regex(^/[^/]+/[^/]+/(info/refs|git-upload-pack|git-receive-pack|info/lfs/.*)$)` (Git
  smart HTTP and LFS; replaces the old `regex(^(\/([^\/\n])+){2,}\.git.*$)`, which needed a `.git`
  suffix). The repository web UI stays behind the login.
- `nginx.ingress.kubernetes.io/service-upstream` dropped (not in the supported annotation set).
- Optional SMTP mailer (new).
- Default resources for Gitea (small: 100m/384Mi, limit 1Gi; medium: 500m/1Gi, limit 2Gi) and its
  init containers (50m/128Mi, limit 256Mi). The Helm test pod is disabled.

## Known limitations

- The upstream chart's configure-gitea script passes the OIDC client secret
  (`gitea admin auth add-oauth/update-oauth --secret "${OIDC_CLIENT_SECRET}"`) and the admin
  password as command-line arguments, so they are visible in the init container's process list
  while it runs. Only inside the pod; accepted.
- The disabled Bitnami subcharts stay vendored inside the upstream `gitea-12.7.0.tgz` (Helm requires
  them in `charts/`); they render nothing. Lint reports `lookup-offline` for their templates.
