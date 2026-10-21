# Miniflux

Miniflux is a minimalist feed reader: subscribe to websites, blogs and podcasts and read everything in one fast, distraction-free list, without ads, tracking or algorithms.

## Features

- RSS, Atom and JSON Feed, OPML import and export
- Clean, keyboard-friendly reader with full-content fetching, search, categories and starred entries
- Works with mobile and desktop apps through the Fever and Google Reader APIs, plus a REST API
- Integrations to save articles to read-it-later, bookmarking and note apps
- Single sign-on through Emporium: every Emporium user gets their own reader at the first sign-in

## Perfect for

People and small teams who want to follow the web on their own terms, with one private reader that works on every device.

## Good to know

- Accounts created by single sign-on are regular users. The local administrator (created at install, password in the app's Secret) can make them administrators under Settings > Users.
- The Miniflux username is the Emporium (Logto) username; no email is needed. An Emporium user whose username matches an existing local Miniflux account (for example `admin`) cannot sign in by SSO.
- Feed reader apps sign in with an API key or the Fever / Google Reader credentials set in Miniflux; these APIs and shared entries (`/share/...`) are reachable without the Emporium login.
