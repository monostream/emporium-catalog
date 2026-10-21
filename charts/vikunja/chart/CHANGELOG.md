# 0.1.0

- New chart: Vikunja 2.7.1 (official image `vikunja/vikunja`), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG), connected with `sslmode=require`; attachments on a volume from the `files` storage integration.
- Single sign-on through Emporium (`sso` OIDC integration, "Sign in with Emporium"); accounts are created at the first sign-in. Vikunja's free edition has no administrator role to map.
- Local login stays on as the break-glass way in; the local administrator is created once after the install, its password is generated into the per-app Secret. Self-registration is off by default.
- API, CalDAV and link shares skip the Emporium login so apps and shared links work.
- Known limit: Vikunja needs an email address in the sign-in; Emporium users without an email cannot use single sign-on.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, SSO login (ES384) with a new Emporium user, local administrator login, registration closed, uninstall without leftovers.
