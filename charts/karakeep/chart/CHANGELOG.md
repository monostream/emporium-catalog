# 0.1.0

- New chart: Karakeep 0.34.0 (official images `ghcr.io/karakeep-app/karakeep`, `ghcr.io/karakeep-app/karakeep-chrome`, `getmeili/meilisearch`), requires Emporium v0.5.0.
- One pod with the app, headless Chrome and Meilisearch sidecars; SQLite database, archives and search index on one volume (`data` storage integration).
- Single sign-on through Emporium (`sso` OIDC integration, "Sign in with Emporium", callback `/api/auth/callback/custom`); accounts are created at the first sign-in and linked to existing accounts by email.
- Karakeep has no administrator mapping or bootstrap account: the first account created is the administrator (documented).
- Only `/api/v1`, `/api/trpc`, `/api/assets`, `/api/public`, health/version and `/public` skip the Emporium login; `/api/auth/*` (sign-up, sign-in) stays behind it, so nobody outside Emporium can create an account or become the first administrator.
