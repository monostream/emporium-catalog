# 0.1.0

- New chart: SearXNG 2026.10.19-81371861f, official `searxng/searxng` image, requires Emporium v0.5.0.
- Stateless: no database or volume; settings come from a ConfigMap (SearXNG defaults plus instance name, safe search, JSON API, image proxy).
- Secret key generated at install and delivered by reference (`SEARXNG_SECRET`).
- Emporium login is the only access control (SearXNG has no accounts or SSO).
- Optional Valkey connection (redis integration, cache mode) switches the rate limiter and bot detection on.
- Optional JSON API (`/search?format=json`), off by default.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21, run 34667a): install with the Valkey connection and the JSON API on, Emporium login, search with live results, JSON API through the logged-in session, uninstall without leftovers.
