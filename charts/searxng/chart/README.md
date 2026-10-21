# SearXNG

SearXNG is a privacy-respecting metasearch engine. It forwards your query to dozens of search engines, merges the results and shows them without ads, trackers or profiling. The engines never see who you are, only your Emporium.

## Features

- Results from 70+ engines in one page: general web, images, videos, news, maps, music, files, science, IT, social media
- No tracking, no profiling, no search history on the server; result images can be proxied so your browser never contacts the source sites
- Per-user preferences (engines, language, safe search, theme) stored in the browser, no account needed
- Optional JSON API for scripts and other apps
- Instant answers, autocomplete and an OpenSearch description so you can add it as a browser search engine

## Perfect for

A household or a team that wants a clean, private starting point for web searches, or an in-cluster search backend for other tools.

## Good to know

- SearXNG has no accounts and no single sign-on. The Emporium login in front of the app is the only gate, so every Emporium user who may open it can search.
- The chart runs the official `searxng/searxng` image (AGPL-3.0-or-later). Releases are date-based; the image tag is pinned to one build.
- The secret key (session and image-proxy tokens) is generated at install and delivered by reference.
- Engines are queried from the cluster's address. Some engines (for example Google, Bing, Brave) rate-limit or block shared server addresses from time to time; SearXNG then shows "unresponsive engines" for that query. That is normal for any SearXNG.
- **JSON API** (input "Enable the JSON API", off by default): turns on `/search?format=json`. Through the public address it stays behind the Emporium login, so scripts need an Emporium session. Apps inside the cluster can call the service directly (`http://<release>-searxng.<namespace>.svc/search?q=...&format=json`; without the Emporium login in between). Everything in the cluster that can reach the service can then search. With the Valkey connection on (rate limiter), such in-cluster calls are answered 429 (no client address header); leave the connection off when other apps use the API.
- **Rate limiter**: enable the optional Valkey connection (the "cache" switch in the install form) to switch on SearXNG's rate limiter and bot detection. This is meant for open instances; behind the Emporium login it is not needed, and it can block scripts that call the JSON API from the cluster. Valkey only holds counters (cache mode, no volume).
- Nothing is persisted: preferences live in the browser, the pod needs no volume.
