# 0.1.0

- New chart: PhotoPrism 261007 (official image `photoprism/photoprism`, Community Edition, AGPL-3.0), requires Emporium v0.5.0.
- SQLite on a `storage` volume (database, thumbnails, sidecars, import folder) plus a separate `originals` volume (two `storage` integrations); PhotoPrism has no supported PostgreSQL mode. One replica.
- Runs as a non-root user: the image's s6 `/init` needs root, so the server (`photoprism start`) is started directly.
- Single sign-on through Emporium (`sso` OIDC integration, ES384 ID tokens): accounts are created at the first sign-in (`PHOTOPRISM_OIDC_REGISTER`), members of the Emporium role `emporium-admin` become administrators (`roles` claim via `PHOTOPRISM_OIDC_GROUP_ROLE`), others get the Community Edition role `guest` (or `admin` by an install input). Client secret by reference.
- Local administrator with a generated install-only password (Secret, by reference); public mode off.
- Share links, the web app, the API and WebDAV skip the Emporium login and are protected by PhotoPrism.
- Indexing workers input (default 2); requests 500m / 1Gi, memory limit 3Gi.
