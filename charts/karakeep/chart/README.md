# Karakeep

Karakeep is a self-hosted bookmark manager and read-it-later app: save links, notes and images, and let it fetch, archive and index everything so you can find it again years later.

## Features

- Save links with a browser extension, mobile apps, the web UI, RSS feeds or the REST API
- Every link is rendered by a headless browser: readable text, screenshot and optional full-page archive are kept even if the site disappears
- Full-text search across titles, notes and page content (Meilisearch)
- Lists, tags, favourites, highlights, notes and bulk import from browser bookmarks, Pocket, Linkwarden and others
- Optional AI tagging and summaries with an OpenAI-compatible or Ollama endpoint (set `extraEnv`, see the upstream documentation)
- Single sign-on through Emporium: every Emporium user gets their own library at the first sign-in

## Perfect for

People and small teams who want a private archive of everything they read on the web, searchable and under their own control.

## Good to know

- **Administrator:** Karakeep has no bootstrap account and no role mapping. The first account that is ever created (by single sign-on or by "Sign up") becomes the administrator; later accounts are regular users, and an administrator can promote them under Admin settings. Sign in once yourself before you share the address. Emporium administrators are not mapped to Karakeep administrators.
- **Email required:** Karakeep identifies accounts by email address. An Emporium user without an email cannot sign in by single sign-on (ask an Emporium administrator to set one). Email addresses can only be set by Emporium administrators, so linking an SSO login to an existing account with the same email is safe and enabled by default.
- **Break-glass:** with "Email and password sign-in" on (the default) the sign-up form creates a local account that works without Emporium. Turn "Allow new accounts" off once everyone has signed in.
- The chart runs three containers in one pod: Karakeep, headless Chrome and Meilisearch. All data (SQLite database, archives, search index) is on one volume. Expect about 1.5 GiB of memory under load while pages are being archived.
- Sign-up and sign-in endpoints (`/api/auth/*`) are behind the Emporium login, so nobody outside Emporium can create an account. Only the REST API (`/api/v1`), tRPC (`/api/trpc`, used by the browser extension and mobile apps), assets and shared lists (`/public/*`) skip the Emporium login; they need a Karakeep API key or session. Karakeep has a single switch for new accounts (password and single sign-on together), so "Allow new accounts" off also stops new SSO accounts.
- **Sign in first:** the person installing must sign in once before sharing the address; that account is the administrator.
- Pages are fetched from inside the cluster, so Karakeep can reach internal addresses only if you allow them with `CRAWLER_ALLOWED_INTERNAL_HOSTNAMES` in `extraEnv`.
