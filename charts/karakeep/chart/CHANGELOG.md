# 0.1.0

- New chart: Karakeep 0.34.0 (official images `ghcr.io/karakeep-app/karakeep`, `ghcr.io/karakeep-app/karakeep-chrome`, `getmeili/meilisearch`), requires Emporium v0.5.0.
- One pod with the app, headless Chrome and Meilisearch sidecars; SQLite database, archives and search index on one volume (`data` storage integration).
- Single sign-on through Emporium (`sso` OIDC integration, "Sign in with Emporium", callback `/api/auth/callback/custom`); accounts are created at the first sign-in and linked to existing accounts by email.
- Karakeep has no administrator mapping or bootstrap account: the first account created is the administrator (documented).
- REST API and shared lists skip the Emporium login so the extension and mobile apps work.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, SSO login with new Emporium users (first account admin, second regular), local email/password sign-up and sign-in, bookmark crawl with Chrome and Meilisearch search, uninstall without leftovers.
