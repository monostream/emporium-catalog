# 0.1.0

- New chart: Calibre-Web Automated v4.0.8 (official image `crocodilestick/calibre-web-automated`, GPL-3.0), requires Emporium v0.5.0.
- SQLite (`app.db`) and the Calibre `metadata.db` on three volumes (`config`, `library`, `ingest`, `storage` integrations); CWA has no PostgreSQL support.
- A setup init container replaces the default `admin` / `admin123` account with a configurable local administrator (generated password in the per-app Secret) before the app starts, and fails the pod if any account keeps the default password.
- Single sign-on through Emporium (`sso` OIDC integration): the init container writes Calibre-Web's generic OIDC provider (discovery URL, client id, client secret from the Secret) into `app.db` at every start and sets the login type to OAuth; the standard login form stays for the local administrator. Admin mapping is not possible (CWA only reads a `groups` claim).
- OPDS (`/opds/*`), Kobo sync (`/kobo/*`) and KOReader sync (`/kosync/*`) skip the Emporium login; they authenticate with CWA's own credentials or tokens.
