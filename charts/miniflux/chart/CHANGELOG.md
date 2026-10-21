# 0.1.0

- New chart: Miniflux 2.3.4 (official image `ghcr.io/miniflux/miniflux`), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG), connected with `sslmode=require`.
- Single sign-on through Emporium (`sso` OIDC integration, "Sign in with Emporium"); accounts are created at the first sign-in (input "Create accounts at the first single sign-on").
- Local administrator created at the first start; the password is generated into the per-app Secret unless set at install.
- REST, Fever and Google Reader APIs and shared entries skip the Emporium login so feed reader apps work.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, SSO login with a new Emporium user (account created), local administrator login, uninstall without leftovers.
