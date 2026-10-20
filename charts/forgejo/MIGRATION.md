# forgejo 0.1.0 / 0.0.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

- `Username`, `Password` (admin): deleted. The chart no longer creates a local admin; see
  "Admins" below. Existing local admins stay in the database untouched.

## Admins (diverges from the catalog main hotfix)

- Forgejo admins are the users with the Logto role `emporium-admin` (Emporium's admin role):
  the `emporium` oauth source uses scopes `email profile roles`, `groupClaimName: roles`,
  `adminGroup: emporium-admin`. New users are auto-registered on first Logto login with admin set
  from the role.
- Catalog main (0.4, hotfix `fix/forgejo-access-admin`) instead turns the admin sync off
  (`groupClaimName: ""`, `adminGroup: ""`). Coordinator-approved divergence for 0.5.
- Forgejo's admin sync also removes admin from users without the role and refuses to remove the
  last admin with an HTTP 500 (`services/user/update.go`, `ErrDeleteLastAdminUser`); it has no
  grant-only mode. To keep that from hitting a sole local admin, the chart creates no local admin,
  and `ACCOUNT_LINKING: login` means an OIDC login is linked to an existing local account only
  after the user enters that account's password. Remaining edge cases: linking a pre-existing sole
  local admin to a Logto user without the role, or removing the role from the last Forgejo admin,
  still yields the 500 on that user's next login; give the user the role (or make another user
  admin first).

## Database

- PostgreSQL via the `db` postgres integration (CloudNativePG cluster `<release>-db`, PostgreSQL 17,
  database and owner `forgejo`, 10Gi grow-only, no extensions), password by `secretKeyRef` from the
  CloudNativePG app Secret (`FORGEJO__DATABASE__PASSWD`).
- TLS: `SSL_MODE=require` (Forgejo cannot load the CloudNativePG CA for verify-full).
- 0.0.x had no working database (the Forgejo 17 chart dropped its bundled PostgreSQL), so there is
  no data to move; 0.1.0 already used this integration via the annotation, same cluster name.

## Data volumes

- `data` (storage integration, default 30Gi, grow-only), mounted at `/data` (repositories, LFS,
  attachments, Bleve index, LevelDB queue). 0.0.x/0.1.0 used the chart's own claim
  `gitea-shared-storage` (kept on uninstall by `helm.sh/resource-policy: keep`); move it with the
  installed-app blueprint (`docs/blueprints/migrate-installed-app-to-v0.5.md`) by choosing it as
  existing claim.

## Hostnames

No extra hosts. `server.ROOT_URL` is set from the hostname.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- OIDC client secret: `<app>-emporium-secrets`, key `oidc.sso.clientSecret`, expanded by the
  configure-gitea init container from `OIDC_CLIENT_SECRET` (was plaintext in the values).
- Admin password: gone with the local admin.
- No plaintext secrets remain.

## Behaviour changes

- The chart sets no `emporium.build/auth-*` annotations (fixes the duplicate `auth-skip-paths` key
  with access public). Skip paths: `/api/*` and `/*/*.git/*` (Git over HTTP). The old
  `regex(^(\/([^\/\n])+){2,}\.git.*$)` form is no longer accepted (skip paths must start with `/`).
- `nginx.ingress.kubernetes.io/service-upstream` dropped (not in the supported annotation set).
