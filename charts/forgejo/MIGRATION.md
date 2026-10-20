# forgejo 0.0.x / 0.1.0 -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

- `Username`, `Password` (local admin): kept under the same keys, now `type: secret` delivered by
  reference (`<app>-emporium-secrets`, keys `username` and `password`). The password is generated
  when left empty. `Username` is a secret input only because Forgejo's chart reads both values from
  one Secret; the field is blank after install.
- `EnableHA` (catalog main 0.0.x): gone since 0.1.0 (the Forgejo 17 chart has no Redis or
  postgresql-ha).

## Admins (diverges from the coordinator-approved Logto mapping of the first 0.2.0 draft)

- Role-based admin sync is **intentionally off**: the `emporium` oauth source sets
  `groupClaimName: ""` and `adminGroup: ""` (empty, so `update-oauth` clears the
  "authentik Admins" mapping of 0.0.x/0.1.0 on upgrade). Forgejo's `adminGroup` would also demote
  every user without the role and answers the last admin's login with HTTP 500
  (`services/user/update.go`, `ErrDeleteLastAdminUser`); Forgejo has no grant-only mode, and the
  rule is "never demote the last admin". Same choice as the catalog main hotfix (635ba4f1).
- The scope `roles` is still requested (Logto sends the role names, e.g. `emporium-admin`), ready
  for a grant-only mapping if Forgejo gets one.
- Granting admin: log in as the local admin (`Username`/`Password` above), then Site
  administration > User accounts > edit the user > "Is administrator". OIDC users are
  auto-registered on first Logto login as regular users.

## Database

- Integration name `postgres` (CloudNativePG cluster `<release>-postgres`, PostgreSQL 17, database
  and owner `forgejo`, 10Gi grow-only, no extensions), password by `secretKeyRef` from the
  CloudNativePG app Secret (`FORGEJO__DATABASE__PASSWD`). TLS: `SSL_MODE=require` (Forgejo cannot
  load the CloudNativePG CA for verify-full).
- Evidence per old version:
  - 0.1.0 (W4, `feat/native-postgres`, staging and emporium-dev only): `emporium.build/postgres`
    annotation; W1's provider names the cluster `cnpg.ClusterName(release) = <release>-postgres`
    (`pkg/postgres/cnpg/manifest.go`, branch `feat/postgres-integration`). The S8 provider keeps
    that name for an integration called `postgres` (`ClusterName(release, integration)`), so a
    0.1.0 install keeps its database. That is why the integration is not called `db`.
  - 0.0.76 / 0.0.77 (catalog main, Forgejo chart 17.2.0): `DB_TYPE: postgres` with no host; the
    Forgejo 17 chart no longer vendors postgresql/postgresql-ha (no `charts/postgresql*` in
    `forgejo-17.2.0.tgz`), so these installs could not start and hold no data.
  - 0.0.75 and older (Forgejo chart 16.x): data in the bundled Bitnami `postgresql` (or
    `postgresql-ha`) subchart StatefulSet, not a CloudNativePG cluster. Existing installs start
    with an empty database; move the data with the installed-app blueprint
    (`docs/blueprints/migrate-installed-app-to-v0.5.md`, dump from the Bitnami pod, restore into
    `<release>-postgres` while the app is on hold).

## Data volumes

- `data` (storage integration, default 30Gi, grow-only), mounted at `/data` (repositories, LFS,
  attachments, Bleve index, LevelDB queue). 0.0.x/0.1.0 used the chart-managed claim
  `gitea-shared-storage`; select it as the existing claim when migrating.
- The upstream chart renders `helm.sh/resource-policy: keep` on `gitea-shared-storage` by default
  (`persistence.annotations` in Forgejo chart 17.2.0), so the stored manifest normally already
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
  and the annotation in the values (the old chart passes `forgejo.persistence.annotations` through), then check the
  stored manifest:

  ```bash
  helm -n <ns> upgrade <release> <catalog-repo>/forgejo --version <installed 0.0.x/0.1.0 version> --reuse-values \
    --set-string 'forgejo.persistence.annotations.helm\.sh/resource-policy=keep'
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

## Behaviour changes

- The chart sets no `emporium.build/auth-*` annotations (fixes the duplicate `auth-skip-paths` key
  with access public). Skip paths: `/api/*` and
  `regex(^/[^/]+/[^/]+/(info/refs|git-upload-pack|git-receive-pack|info/lfs/.*)$)` (Git smart HTTP
  and LFS; same rule as the catalog main hotfix). The repository web UI stays behind the login.
- `nginx.ingress.kubernetes.io/service-upstream` dropped (not in the supported annotation set).

## Known limitations

- The upstream chart's configure-gitea script passes the OIDC client secret
  (`gitea admin auth add-oauth/update-oauth --secret "${OIDC_CLIENT_SECRET}"`) and the admin
  password (`gitea admin user create/change-password --password ...`) as command-line arguments, so
  they are visible in the init container's process list while it runs. Only inside the pod;
  accepted (the upstream gitea chart does the same).
