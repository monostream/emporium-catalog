# 0.1.0

- New chart: Kavita 0.9.1 (official image `jvmilazz0/kavita`, GPL-3.0), requires Emporium v0.5.0.
- SQLite on a config volume plus a separate library volume (two `storage` integrations); Kavita has no PostgreSQL support.
- Single sign-on through Emporium (`sso` OIDC integration, ES384 ID tokens): the provider and the client secret are rendered into `appsettings.json` in a memory volume at every start (Kavita itself persists the client secret in SQLite and the token key in its backups), accounts are created at the first sign-in with the Login, Pleb and Download roles.
- Readiness waits for the setup sidecar (shared emptyDir marker, per pod), so the Service has no endpoint before the administrator exists; a changed administrator password is tolerated (setup reports ready and leaves settings alone, only when a marker on the config volume shows the settings were applied once; otherwise it retries; server errors are retried too).
- A setup sidecar registers the local administrator at the first start (password generated into the per-app Secret), switches statistics off, enables account provisioning and creates a default "Books" library.
- OPDS (`/api/opds/*`) and KOReader sync (`/api/koreader/*`) skip the Emporium login; they authenticate with the per-user API key in the path.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, SSO login with new Emporium users (account created with the default roles and library, books visible), local administrator login, pod restart, uninstall without leftovers.
