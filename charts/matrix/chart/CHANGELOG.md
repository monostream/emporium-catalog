# 0.1.1

Published on 23 October 2026

- synapse from v1.163.0 to v1.163.1

# 0.1.0

- New chart: Matrix with Synapse v1.163.0 (`ghcr.io/element-hq/synapse`) and Element Web v1.12.32 (`ghcr.io/element-hq/element-web`) on one host; Element's nginx forwards `/_matrix`, `/_synapse` and `/.well-known/matrix` to Synapse. Requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG), password passed as `PGPASSWORD` by reference; media store and signing key on the `media` storage integration.
- Single sign-on through Emporium (`sso` OIDC integration, native Synapse `oidc_providers`, client secret read from a mounted file); user id is the Emporium username; existing accounts are never linked.
- Registration closed; federation off by default (input "Federation"); password login on by default for the break-glass administrator created with the registration shared secret.
- Macaroon, form and registration secrets are generated and mounted as files; nothing secret is in the ConfigMaps.
- The Emporium login protects the Element page only; Matrix API, SSO callback and server discovery paths skip it.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, single sign-on login (ES384 ID token) with an Emporium user and an Emporium admin, break-glass administrator created with register_new_matrix_user and password login, message sent in an encrypted room, uninstall without leftovers.
- The Ingress has one path; Element's nginx forwards the Matrix paths to Synapse (the Emporium login proxy doubles the path prefix of multi-path ingresses).
