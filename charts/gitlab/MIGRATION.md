# gitlab 0.3.x -> 0.4.0 (Emporium 0.5)

Emporium 0.5 cannot upgrade a 0.4 app in place: an installed GitLab is uninstalled and installed
again with the installed-app blueprint (`docs/blueprints/migrate-installed-app-to-v0.5.md`). Read
"Before uninstalling" first.

## Removed and renamed inputs

- `RepositoryStorageSize`: same key, `byteSize`, default 50Gi, now install-only (Gitaly
  StatefulSet volume claim template).
- `PrivilegedRunner`: same key, `boolean`, default false.
- `ObjectStorageSize`: deleted. The object storage size is the `objects` integration's size
  (20Gi default, grow-only), chosen in the install form.

## Database

- Not replaced: the `postgres` integration keeps the CloudNativePG cluster name
  `<release>-postgres` that 0.3.0's `emporium.build/postgres` annotation created (PostgreSQL 18,
  database `gitlabhq_production`, owner `gitlab`, extensions `amcheck`, `btree_gist`, `pg_trgm`,
  `plpgsql`, 20Gi grow-only). Whether the cluster survives the uninstall and is reused depends on
  the installed-app blueprint.
- Sizing moved to the profiles: small 1 instance, 250m/1Gi, `shared_buffers` 256MB,
  `max_connections` 200; medium 1 instance, 1 CPU/4Gi, `shared_buffers` 1GB, `max_connections` 400
  (0.3.0: 500m/2Gi, 1GB, 400).
- TLS: GitLab's libpq default `sslmode=prefer` (encrypted, not verified); the GitLab chart has no
  sslmode setting.
- 0.2.x and older (bundled PostgreSQL of GitLab chart 9.x): already not migrated by 0.3.0.

## Redis and object storage (replaced)

- Redis: the bundled Valkey chart (`<release>-valkey`, secret `<release>-valkey-auth`) became the
  `redis` integration (Valkey `<release>-redis`, persistent). It holds caches, sessions and Sidekiq
  queues; existing installs start with an empty Redis (users sign in again, queued jobs are lost).
- Object storage: the bundled RustFS chart (`<release>-rustfs`, secret
  `<release>-rustfs-credentials`, bucket Job) became the `objects` integration (RustFS
  `<release>-objects`, same 15 buckets, created by Emporium). **Existing installs start with empty
  object storage**: CI artifacts, uploads, LFS objects, packages, container images, Terraform state
  and backups of 0.3.x are not moved.

## Before uninstalling a 0.3.x install

1. Back up GitLab with its own tool (database, repositories and object storage in one archive):

   ```bash
   kubectl -n <ns> exec deploy/<release>-toolbox -- backup-utility
   kubectl -n <ns> exec deploy/<release>-toolbox -- ls /srv/gitlab/tmp/backups   # or the gitlab-backups bucket
   ```

   Copy the archive out of the cluster (`kubectl cp`, or `aws s3 cp` from the old RustFS
   `gitlab-backups` bucket).
2. Keep the secrets GitLab encrypts data with: `<release>-rails-secret` (and
   `<release>-gitlab-initial-root-password`). They are created by GitLab's shared-secrets Job,
   not by Helm, so the uninstall leaves them; a reinstall under the same name reuses them. Save a
   copy anyway (`kubectl get secret -o yaml`).
3. Gitaly's claim `repo-data-<release>-gitaly-0` (StatefulSet) also stays after the uninstall and
   is reused by a reinstall under the same name and namespace.
4. After installing 0.4.0 (app on hold if you restore), upload the archive into the new
   `gitlab-backups` bucket and restore:
   `kubectl -n <ns> exec deploy/<release>-toolbox -- backup-utility --restore -t <timestamp>`
   (https://docs.gitlab.com/charts/backup-restore/restore/).

## Hostnames

- `registry.<host>` -> `<subdomain>-registry.<zone>`; `kas.<host>` -> `<subdomain>-kas.<zone>`
  (extra hosts `registry`, `kas` of the `web` integration). Update `docker login` commands, CI
  variables and agent configurations that name the old hosts.

## TLS secret

`gitlab-webservice-tls`, `gitlab-registry-tls` and `gitlab-kas-tls` became the integration's
`TLSSecretName` (wildcard zones: the replicated `emporium-wildcard-<zone>` for all three Ingresses;
perHost zones: `<TLSSecretName>` for the web host, `<TLSSecretName>-registry` and
`<TLSSecretName>-kas` for the others, issued per Ingress; those two are not deleted by the
uninstall).

## Secrets

- PostgreSQL password: by reference from the CloudNativePG app Secret (as in 0.3.0).
- Redis password: by reference (`<app>-emporium-secrets`, key from the integration's `PasswordKey`).
- SMTP password: by reference (`<app>-emporium-secrets`).
- **Plaintext (lint `plaintext-secret-output`, accepted)**: the OIDC client secret and the S3
  access/secret key reach the chart as values, because GitLab reads them only inside YAML/INI
  documents: the OmniAuth provider (`<release>-oidc-provider`), the Fog connection, registry storage
  and `s3cfg` (`<release>-object-storage`) and the runner cache (`<release>-runner-cache`, kept
  separate so the runner does not mount the whole app Secret). 0.3.0 generated the S3 keys with
  `lookup` in the chart; that `lookup` is gone.

## Behaviour changes

- Profiles: `small` (default) runs one web pod with two Puma workers, one Sidekiq pod
  (concurrency 10), no agent server (kas) and no metrics exporter; `medium` runs 2-4 web pods with
  four workers, 1-2 Sidekiq pods, kas and the exporter. 0.3.0 ran the upstream defaults (2-10 web
  pods).
- The chart sets no `emporium.build/auth-*` annotations; the skip paths are the `web` integration's
  `skipPaths` (same list; the Git regex is `regex(^(/[^/]+){2,}\.git(/.*)?$)`).
- Dropped annotations: `kubernetes.io/tls-acme`, `nginx.ingress.kubernetes.io/service-upstream`
  (set by the chart; upstream still adds its own nginx defaults, which other controllers ignore).
- The kas gRPC Ingress (nginx only) is off; agents use `wss://<subdomain>-kas.<zone>`.
- The runner setup Job is unchanged (instance runner, token written to
  `<release>-gitlab-runner-secret`); the runner cache uses the `runner-cache` bucket of `objects`.
- The upstream chart and its openbao/gateway subcharts call `lookup` (lint `lookup-offline`): no
  manifest diff in preview.
