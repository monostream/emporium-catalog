# Grocy

Grocy is an ERP for your kitchen and household: know what is in stock, what is about to expire and what to buy next, and plan meals, chores and tasks in one place.

## Features

- Stock with locations, best-before dates, minimum amounts, barcode scanning and product pictures
- Shopping lists that fill themselves from missing stock and recipes
- Recipes with ingredient stock check, meal plan and nutritional values
- Chores, tasks, batteries and equipment with due dates and a calendar
- REST API and a stock-aware companion app ecosystem (mobile apps, Home Assistant)
- Your data stays in one SQLite database on your own storage volume

## Perfect for

Households and small shared flats that want to stop buying the third jar of mustard.

## Good to know

- Grocy sits behind the Emporium login. Grocy keeps its own accounts and shows its own login page after it: sign in as `admin` (the local administrator) and add other people under the user menu > Manage users. Grocy has no OpenID Connect, so Emporium identities are not mapped to Grocy users.
- Grocy creates the account `admin` with the password `admin` when it sets up an empty database. This chart replaces that password with a generated one (in the app's Secret, or the one you enter at install) in an init container before Grocy serves its first request. Change it in Grocy if you like; it is not reset on restart.
- Grocy can trust a user name sent by a reverse proxy. The Emporium login forwards `X-Auth-Request-User`, but that is an opaque user id, not a name, and the `/api/*` paths skip the Emporium login, where a client could send the header itself. So the chart keeps the default login: the init container deletes any persisted `data/settingoverrides` for `AUTH_CLASS`, `DISABLE_AUTH`, `MODE`, reverse-proxy and LDAP settings at every start, evaluates the effective Grocy configuration (including `config.php` and `GROCY_*` variables from `extraEnv`) and refuses to start unless it is default authentication in production mode with authentication enabled. Do not set these in `extraEnv` or `config.php`.
- The REST API (`/api/*`) skips the Emporium login, because Grocy's own pages, companion apps and Home Assistant call it with Grocy credentials (session cookie or a `GROCY-API-KEY` header from user menu > Manage API keys). API keys are long random strings and are not rate limited: if you do not use companion apps, put an IP allowlist on the host.
- Grocy publishes no container image; the chart uses the linuxserver.io image (nginx, PHP and s6). It starts as root and drops nginx and PHP to an unprivileged user, so the pod does not run as non-root. All capabilities are dropped except the few it needs.
- Updates are manual: the image is pinned to the tested linuxserver build `v4.7.1-ls346` (by digest), and the catalog has no `deps.json` for it because linuxserver rebuilds (`-lsN`) would count as app versions. Bump `image.tag` and `appVersion` together.
- Settings such as currency or language are Grocy user settings; instance-wide defaults can be set as `GROCY_*` environment variables through `extraEnv` (see `config-dist.php` upstream).
- Uploads up to 50 MiB are allowed through the ingress.
- Backup: the volume holds `data/grocy.db` (SQLite) and uploaded pictures.
