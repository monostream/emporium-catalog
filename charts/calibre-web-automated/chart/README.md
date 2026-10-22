# Calibre-Web Automated

Calibre-Web Automated (CWA) is a self-hosted ebook library: a clean web reader and catalogue on top of a Calibre library, with a drop folder that imports, converts and tidies new books automatically.

## Features

- Browse, search, read and download your Calibre library in the browser, with shelves, series and per-user settings
- Ingest folder: drop EPUB, PDF, MOBI, AZW3 and many more formats and they are imported, converted and given covers and metadata
- Metadata editing and bulk edits, duplicate detection, EPUB fixer and send-to-eReader by e-mail
- OPDS catalogue for reader apps, Kobo sync and KOReader progress sync
- Several users with their own roles, shelves and reading progress
- Single sign-on through Emporium: every Emporium user gets their own account at the first sign-in

## Perfect for

Households and small groups who keep their ebooks on their own server and want a tidy library that follows them to the phone, tablet and e-reader.

## Good to know

- **Storage.** Three volumes: `config` (app settings database, logs, import history), `library` (the Calibre library: `metadata.db` plus one folder per author) and `ingest` (the drop folder, mounted at `/cwa-book-ingest`). CWA uses SQLite and Calibre's `metadata.db` only, there is no PostgreSQL support, so there is exactly one replica and all three volumes belong in every backup. Copy books into the ingest volume (for example with `kubectl cp`) or upload them in the web UI; the ingest service imports new files within a minute.
- **Local administrator.** CWA ships with the account `admin` / `admin123`. An init container replaces it before the app starts: the account is renamed to the name from the install form (default `cwa-admin`) and gets the generated password from the app's Secret. The default password is never served, and the pod does not start if any account still has it. The password sets the account only once; if you change it in the app later, the Secret value is no longer valid. A local account with the same name as an Emporium user blocks that user's single sign-on.
- **Single sign-on.** The "Emporium" button on the login page uses Calibre-Web's generic OpenID Connect provider (discovery from the issuer). CWA reads the user name and e-mail from the provider's userinfo endpoint, so the ID token algorithm (ES384 at Logto) does not matter. The account is created at the first sign-in and named like the Emporium username; CWA requires a unique e-mail value per account and most Emporium users have no e-mail, so the account's e-mail field holds the stable provider subject id (`sub`) instead of a real address. A single sign-on login is never linked to a local account by e-mail. The standard login form stays, so the local administrator can always sign in.
- **Roles.** CWA grants administrator rights only from a `groups` claim, which Emporium does not send (it sends `roles`). Every single sign-on account is therefore a regular user (it can browse, read online, download, manage its own shelves and change its own password, which the first start sets as the default for new accounts); the local administrator promotes users under Admin > Edit users.
- **Client secret.** The init container writes the OIDC client secret into CWA's `app.db` on the config volume, because CWA reads its providers only from there. Treat the config volume and its backups as secret. The secret is taken from the Emporium Secret at every start, so rotation follows.
- **Reader apps.** `/opds/*` (HTTP basic auth), `/kobo/*` (device token in the path) and `/kosync/*` (KOReader sync) skip the Emporium login and authenticate with CWA itself. Single sign-on accounts have no password: set one in CWA (profile > password) before you use OPDS with that account, or use the local administrator. Everything else, including the web UI and downloads, stays behind the Emporium login.
- **Sessions.** The first start sets CWA's session protection to "basic". The stock "strong" mode ends a session whenever the client address the app sees changes, and behind the ingress that address is a different proxy pod from one request to the next, so users would be logged out after every page.
- **Resources.** The image is large (about 600 MB compressed, with Calibre's tools) and conversions are memory hungry. The `small` profile requests 768 Mi and limits memory to 2 Gi; raise the limit for large conversions.
- **Container user.** The image (linuxserver base, s6) starts as root with a few capabilities (chown, setuid/setgid, dac_override, fowner) and runs the app as user 1000.
