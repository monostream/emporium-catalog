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
- **Email required:** Karakeep identifies accounts by email address. An Emporium user without an email cannot sign in by single sign-on (ask an Emporium administrator to set one).
- **Single sign-on only by default:** email and password sign-up and sign-in are off (`DISABLE_PASSWORD_AUTH`), and linking a single sign-on login to an existing account by email is off. Both stay off because Karakeep does not verify the email of a local sign-up: with password sign-up on, any Emporium user could register another person's email address and take over that person's first sign-in. The "Email and password sign-in" input turns the form on as a local fallback; do not combine it with "Link single sign-on to existing accounts by email". Even then, the sign-in form is only reachable with an Emporium session, so it is a fallback for a broken Emporium-to-Karakeep link, not for an Emporium outage.
- **Allow new accounts** is Karakeep's single switch for new accounts; turning it off also stops new single sign-on accounts.
- The chart runs three containers in one pod: Karakeep, headless Chrome and Meilisearch. All data (SQLite database, archives, search index) is on one volume. Expect about 1.5 GiB of memory under load while pages are being archived.
- The browser sign-in and sign-up endpoints (`/api/auth/*`) are behind the Emporium login. These paths skip it: the REST API (`/api/v1`), tRPC (`/api/trpc`, used by the browser extension and mobile apps), assets (`/api/assets`, `/api/public`) and shared lists (`/public/*`). Most of them need a Karakeep API key or session. Exceptions that work without any session: lists and RSS feeds an owner made public, signed public asset links, and accepting an invitation an administrator issued (`invites.accept` creates a regular user from the token, even when new accounts are off). Password-to-API-key exchange (`apiKeys.exchange`) is refused while password sign-in is off.
- **Sign in first:** the person installing must sign in once before sharing the address; that account is the administrator.
- Pages are fetched from inside the cluster, so Karakeep can reach internal addresses only if you allow them with `CRAWLER_ALLOWED_INTERNAL_HOSTNAMES` in `extraEnv`.
