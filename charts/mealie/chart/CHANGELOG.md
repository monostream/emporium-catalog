# 0.1.0

- New chart: Mealie 3.29.0 (official image `ghcr.io/mealie-recipes/mealie`), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG), connected with `sslmode=require`; recipe images and backups on the `data` volume.
- Single sign-on through Emporium (`sso` OIDC integration, "Sign in with Emporium"); Emporium administrators (role `emporium-admin`) become Mealie administrators. Accounts are created at the first sign-in.
- Mealie's built-in administrator (`changeme@example.com` / `MyPassword`) is replaced right after the first start by `admin` with a generated password (a small sidecar uses the Mealie API).
- The REST API (`/api/*`) skips the Emporium login so mobile apps and integrations work with API tokens.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, SSO login as administrator and as plain user (admin mapping), local administrator login, default login rejected, uninstall without leftovers.
