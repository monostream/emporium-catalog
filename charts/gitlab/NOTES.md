# Notes on the GitLab chart

Installing GitLab through Emporium needs no manual steps.

## What Emporium sets up

- **Sign-in**: GitLab signs users in with Emporium's identity provider (Logto) over OpenID Connect. Opening GitLab redirects to Logto; accounts are created on first sign-in.
- **Administrators**: users with the Logto role `emporium-admin` become GitLab administrators when they sign in; users without it lose administrator rights on their next sign-in. GitLab CE ignores the OIDC `admin_groups` option (Premium only), so a small Rails initializer (`templates/_emporium-rails.tpl`, mounted into the webservice pods) maps the `roles` claim of Logto's userinfo response to GitLab's admin flag. Like `admin_groups`, it sets the flag while GitLab looks up the user in the OIDC callback, before any GitLab two-factor prompt, so it also works for users with GitLab two-factor authentication. Role changes take effect on the next sign-in. Users who sign in otherwise (such as `root`) are not touched. The role is set by `global.emporium.adminRole`; changing it or the initializer rolls the webservice pods.
- **PostgreSQL**: Emporium creates a CloudNativePG cluster `<name>-postgres` from the `emporium.build/postgres` annotation in `Chart.yaml` (database `gitlabhq_production`, owner `gitlab`, PostgreSQL 18, extensions `amcheck`, `btree_gist`, `pg_trgm`, `plpgsql`) and passes the connection to GitLab. The CloudNativePG operator must be installed in the cluster.
- **Redis**: a Valkey instance (`<name>-valkey`, official Valkey chart) with a generated password.
- **Object storage**: a RustFS instance (`<name>-rustfs`, official RustFS chart, only reachable inside the cluster) for artifacts, uploads, LFS, packages, Terraform state, secure files, the dependency proxy, container images, backups and the runner cache. The `<name>-buckets-<revision>` Job creates the buckets. GitLab and the registry proxy all downloads, so clients never talk to RustFS directly.
- **Runner**: the `<name>-runner-setup-<revision>` Job waits for GitLab, creates an instance runner with `gitlab-rails runner` (toolbox image and configuration, no access to other pods), stores its token in `<name>-gitlab-runner-secret` and rolls the bundled GitLab Runner when the token changed. This can take a few minutes after the first install. The runner takes untagged jobs from every project, so its job containers are not privileged; the **Privileged CI Jobs** setting turns that on (e.g. for Docker-in-Docker), which gives every project root access to the cluster's nodes.

Credentials for Valkey and RustFS are generated on the first install and kept on upgrades (`<name>-valkey-auth`, `<name>-rustfs-credentials`).

## Access

The Emporium access setting (public, authenticated, admins) applies to the GitLab web interface. Git over HTTPS, the API (also used by runners), OAuth, sign-in and the OIDC callback bypass Emporium's proxy because GitLab authenticates them itself. The registry (`registry.<host>`) and the agent server (`kas.<host>`) are not behind Emporium's proxy for the same reason.

## Break-glass access

The `root` account still exists. Its password is in the secret `<name>-gitlab-initial-root-password`; sign in at `/users/sign_in?auto_sign_in=false`. Normally this is not needed.

```bash
export NAMESPACE=gitlab
export NAME=gitlab
kubectl get secret -n $NAMESPACE $NAME-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 --decode; echo
```

## Upgrading from 0.2.x

0.3.0 replaces the bundled PostgreSQL, Redis and MinIO of GitLab chart 9.x, which upstream removed in chart 10.0. Data of existing installations is not migrated: install GitLab again, or migrate by hand following https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/.

## Uninstalling

Gitaly's repository volume (StatefulSet) and the RustFS data volume (`helm.sh/resource-policy: keep`) stay after uninstalling; delete the PersistentVolumeClaims to remove the data.
