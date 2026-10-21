# Notes on the GitLab chart

Installing GitLab through Emporium needs no manual steps.

## What Emporium sets up

- **Sign-in**: GitLab signs users in with Emporium's identity provider (Logto) over OpenID Connect. Opening GitLab redirects to Logto; accounts are created on first sign-in.
- **Administrators**: users with the Logto role `emporium-admin` become GitLab administrators when they sign in; users without it lose administrator rights on their next sign-in. GitLab CE ignores the OIDC `admin_groups` option (Premium only), so a small Rails initializer (`templates/_emporium-rails.tpl`, mounted into the webservice pods) maps the `roles` claim of Logto's userinfo response to GitLab's admin flag. Like `admin_groups`, it sets the flag while GitLab looks up the user in the OIDC callback, before any GitLab two-factor prompt, so it also works for users with GitLab two-factor authentication. Role changes take effect on the next sign-in. Users who sign in otherwise (such as `root`) are not touched. The role is set by `global.emporium.adminRole` (a role name; the `.AdminScope` of the oidc integration is the API scope `admin`, which is not part of the `roles` claim, so it cannot be used here; set it only if Emporium runs with another `EMPORIUM_ADMIN_ROLE`); changing it or the initializer rolls the webservice pods.
- **Account linking**: `autoLinkUser` links a first OpenID Connect sign-in to an existing GitLab account with the same email. GitLab does not check `email_verified` for this, so the same initializer only allows the link when Logto's userinfo says `email_verified: true`. Otherwise the sign-in is refused (the email is taken) and nothing is taken over; the owner can sign in with the password and add the identity, or the email can be verified in Logto. Users already linked by their OIDC subject sign in as before.
- **PostgreSQL**: the `postgres` integration (CloudNativePG cluster `<name>-postgres`, database `gitlabhq_production`, owner `gitlab`, PostgreSQL 18, extensions `amcheck`, `btree_gist`, `pg_trgm`, `plpgsql`). The password is read from the CloudNativePG app Secret. The CloudNativePG operator must be installed in the cluster.
- **Redis**: the `redis` integration (Valkey `<name>-redis`, persistent, 2Gi volume, 1Gi max memory in the small profile); the password is read from the app's Secret.
- **Object storage**: the `objects` integration (RustFS `<name>-objects`, only reachable inside the cluster, 20Gi by default) for artifacts, uploads, LFS, packages, Terraform state, secure files, the dependency proxy, container images, backups and the runner cache. Emporium creates the buckets. GitLab and the registry proxy all downloads, so clients never talk to the object storage directly.
- **Email** (optional): the `mail` SMTP integration; the password is read from the app's Secret.
- **Runner**: the `<name>-runner-setup-<revision>` Job waits for GitLab, creates an instance runner with `gitlab-rails runner` (toolbox image and configuration, no access to other pods), stores its token in `<name>-gitlab-runner-secret` and rolls the bundled GitLab Runner when the token changed. This can take a few minutes after the first install. The runner takes untagged jobs from every project, so its job containers are not privileged; the **Privileged CI Jobs** setting turns that on (e.g. for Docker-in-Docker), which gives every project root access to the cluster's nodes.

Emporium generates the Redis and object storage credentials. GitLab reads the S3 keys and the OIDC client secret only from YAML documents (`<name>-object-storage`, `<name>-runner-cache`, `<name>-oidc-provider`), which the chart renders from values.

## Access

The Emporium access setting (public, authenticated, admins) applies to the GitLab web interface. Git over HTTPS, the API (also used by runners), OAuth, sign-in and the OIDC callback bypass Emporium's proxy because GitLab authenticates them itself. The registry and the agent server (medium profile) have their own hostnames (ingress integrations `registry` and `kas`, subdomains chosen at install) and are not behind Emporium's proxy for the same reason.

## Break-glass access

The `root` account still exists. Its password is in the secret `<name>-gitlab-initial-root-password`; sign in at `/users/sign_in?auto_sign_in=false`. Normally this is not needed.

```bash
export NAMESPACE=gitlab
export NAME=gitlab
kubectl get secret -n $NAMESPACE $NAME-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 --decode; echo
```

## Upgrading from 0.3.x and older

See `MIGRATION.md`. Emporium 0.5 installs GitLab anew; data of older installations is not migrated automatically.

## Uninstalling

Gitaly's repository volume (StatefulSet claim `repo-data-<name>-gitaly-0`) stays after uninstalling; delete it to remove the repositories. The database, Redis and object storage follow the keep/delete choice of the uninstall.
