# ghost 1.0.x -> 1.1.0 (Emporium 0.5)

## Removed and renamed inputs

- `Username`, `Password`, `Email`, `Title`: deleted. They fed the Bitnami image's first-start
  bootstrap; the official `ghost` image has none. The owner account and blog title are created in
  Ghost's setup screen at `/ghost/` on the first visit (see Behaviour changes for access). A migrated install keeps its users from the restored database.
- `StorageSize`: deleted. The content volume is the `content` storage integration (default 8Gi,
  grow-only, existing claim selectable).
- New generated secret inputs (section Database): `DatabasePassword` (MySQL user `ghost`) and
  `DatabaseRootPassword`. MySQL applies them only when its data directory is empty; do not change
  them after install.

## Database

- Replaced: yes. Old: the Bitnami `mysql` subchart of the Bitnami Ghost chart 25.0.4 (StatefulSet
  `<release>-mysql`, image `bitnami/mysql:9.4.0`, claim `data-<release>-mysql-0`, database
  `bitnami_ghost`, user `bn_ghost`, passwords in the `lookup`-kept Secret `<release>-mysql`).
  New: an in-chart StatefulSet `<release>-mysql` with the official `mysql:8.4.11` image (MySQL 8.4
  LTS, the version Ghost 6 supports), database and user `ghost`, data on the `mysql` storage
  integration (default 8Gi, grow-only). There is no MySQL provider in Emporium 0.5 (D12); this is
  not a postgres/redis/objectStorage provider case.
- Existing installs start with an empty database. The data does not move with the chart; MySQL
  9.4 data files cannot be opened by 8.4, so move it logically (installed-app blueprint,
  `docs/blueprints/migrate-installed-app-to-v0.5.md`):

  ```bash
  # before the 0.4 uninstall, from the old MySQL pod (password: key mysql-root-password of Secret <release>-mysql)
  kubectl -n <ns> exec <release>-mysql-0 -- sh -c \
    'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction --no-tablespaces --set-gtid-purged=OFF bitnami_ghost' > ghost.sql
  # after installing 1.1.0, with Ghost scaled to 0
  kubectl -n <ns> scale deploy/<release>-ghost --replicas=0
  kubectl -n <ns> exec -i <release>-mysql-0 -- sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" ghost' < ghost.sql
  kubectl -n <ns> scale deploy/<release>-ghost --replicas=1   # Ghost migrates the schema on start
  ```

  The Bitnami image reads the root password from a file variable (`MYSQL_ROOT_PASSWORD_FILE`) in
  some versions; if `$MYSQL_ROOT_PASSWORD` is empty in the old pod, pass the password from the
  Secret instead. The new pod has `MYSQL_ROOT_PASSWORD` from `<app>-emporium-secrets`.
- TLS to the database: none; MySQL and Ghost talk inside the namespace over the headless Service.

## Data volumes

- `content` (storage integration, default 8Gi, grow-only) at `/var/lib/ghost/content` (images,
  media, themes, settings files, logs).
- `mysql` (storage integration, default 8Gi, grow-only) at `/var/lib/mysql`.
- Old layout: the Bitnami chart mounted its claim (`<release>-ghost`, or `<release>` when the
  release name contains `ghost`) at `/bitnami/ghost`, with Ghost's content in the `content/`
  subdirectory. The layout differs, so do not select the old claim as the new `content` claim;
  copy `content/images`, `content/media`, `content/files` and `content/themes` from it into the
  new claim (for example with a temporary pod mounting both) while Ghost is scaled to 0.
- **The old content claim is deleted by a 0.4 uninstall.** It is rendered by Helm without
  `helm.sh/resource-policy: keep` (`persistence.annotations` is empty in Bitnami Ghost 25.0.4).
  Check the stored manifest first:

  ```bash
  helm -n <ns> get manifest <release> | grep -B2 -A8 'kind: PersistentVolumeClaim'   # resource-policy: keep?
  ```

- **Why a live annotation is not enough:** `kubectl annotate` on the claim protects a
  `helm upgrade`, but `helm uninstall` decides from the manifest stored in the release. The 0.5
  path for an installed 0.4 app is uninstall + reinstall (`updateApp` refuses `NEEDS_MIGRATION`
  apps), so the keep annotation has to be in the stored manifest first.
- **Before uninstalling (preferred):** upgrade once more with the **old** chart version and the
  annotation, then check the stored manifest:

  ```bash
  helm -n <ns> upgrade <release> <catalog-repo>/ghost --version <installed 1.0.x version> --reuse-values \
    --set-string 'ghost.persistence.annotations.helm\.sh/resource-policy=keep'
  helm -n <ns> get manifest <release> | grep -B2 -A8 'kind: PersistentVolumeClaim'   # must show resource-policy: keep
  ```

  The old MySQL claim `data-<release>-mysql-0` comes from a volumeClaimTemplate; `helm uninstall`
  does not delete it. Delete it yourself once the dump is restored and checked.
- **If that upgrade is not possible:** back the content up (copy it out of the pod), or set the
  bound PV to `Retain` before the uninstall and bind it to a temporary claim afterwards
  (`spec.volumeName`) to copy the files.

## Hostnames

No extra hosts. Ghost's `url` is `https://<Hostname>`.

## TLS secret

`<release>-tls` (Bitnami `ingress.tls: true`) became the integration's `TLSSecretName` (zone
dependent).

## Secrets

- MySQL passwords: `<app>-emporium-secrets`, keys `DatabasePassword` and `DatabaseRootPassword`
  (were generated by the chart template with `lookup` + `randAlphaNum`).
- SMTP password: `<app>-emporium-secrets`, key `smtp.mail.password`, as env
  `mail__options__auth__pass`.
- No plaintext secrets remain (the old admin password input was plaintext).

## Behaviour changes

- Access defaults to authenticated, without skip paths, so a stranger cannot claim the first-run
  owner setup at `/ghost/`. Create the owner account, then switch the app's access to public to
  publish the blog (Ghost Admin keeps its own login). A skip-path rule for "everything except
  `/ghost/`" is not possible: Emporium rejects skip paths that match `/` and deep paths as opening
  the whole app.
- No `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations from the chart.
- `proxy-body-size` raised from 10m to 50m (Ghost's default upload limit for images and themes).
- Ghost and MySQL run as non-root (uid 1000 and 999) with all capabilities dropped.
- MySQL is pinned to the 8.4 LTS line (not tracked by `deps.json`); bump it by hand within 8.4.
