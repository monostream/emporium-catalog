# 0.1.0

- New chart: PhotoPrism 261007 (official image `photoprism/photoprism`, Community Edition, AGPL-3.0), requires Emporium v0.5.0.
- SQLite on a `storage` volume (database, thumbnails, sidecars, import folder) plus a separate `originals` volume (two `storage` integrations); PhotoPrism has no supported PostgreSQL mode. One replica.
- Runs as a non-root user: the image's s6 `/init` needs root, so the server (`photoprism start`) is started directly.
- Single sign-on through Emporium (`sso` OIDC integration, ES384 ID tokens), the recommended login: accounts are created at the first sign-in (`PHOTOPRISM_OIDC_REGISTER`); the `roles` claim is mapped with `PHOTOPRISM_OIDC_GROUP_ROLE=emporium-admin=admin` (deterministic whatever the order of the roles); there is no automatic demotion, remove the admin role by hand with `photoprism users mod --role=guest <name>`. New accounts without a mapped role get `guest` (or `admin` by an install input). Client secret by reference.
- Local administrator with a generated install-only password (Secret, by reference); public mode off.
- `access: public`: PhotoPrism's own login (with its login-failure limiter) is the gate, share links work for anonymous viewers; no skip paths. The WebDAV input is only the default for new SSO accounts.
- Indexing workers input (default 2); requests 500m / 1Gi, memory limit 3Gi.
