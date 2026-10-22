# 0.1.0

- New chart: Mealie 3.29.0 (official image `ghcr.io/mealie-recipes/mealie`), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG), connected with `sslmode=require`; recipe images and backups on the `data` volume.
- Single sign-on through Emporium (`sso` OIDC integration, "Sign in with Emporium"); Emporium administrators (role `emporium-admin`) become Mealie administrators. Accounts are created at the first sign-in and identified by the Emporium username.
- Mealie's built-in administrator (`changeme@example.com` / `MyPassword`) is replaced before Mealie starts by `mealie-local-admin` with a generated password: an init container runs Mealie's database init and then checks and updates the database directly (no HTTP, no state). An already customised account is left alone; passwords under 8 characters are rejected. Break-glass: Mealie's `change_password` script inside the pod.
- The REST API areas used by mobile apps and integrations skip the Emporium login (validators, attachments, admin and explore stay protected).
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, SSO login as administrator and as plain user (admin mapping), local administrator login, default login rejected, uninstall without leftovers.
