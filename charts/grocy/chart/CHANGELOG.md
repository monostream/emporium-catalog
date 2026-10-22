# 0.1.0

- New chart: Grocy 4.7.1 (MIT), requires Emporium v0.5.0. Grocy publishes no container image, so the chart uses the linuxserver.io image `lscr.io/linuxserver/grocy`.
- SQLite database, uploads and `config.php` on one storage volume (`/config`); a single replica.
- Behind the Emporium login (`access: authenticated`); Grocy keeps its own accounts. Header (reverse proxy) login is not enabled.
- The image is pinned to the tested linuxserver build `v4.7.1-ls346` by digest; there is no `deps.json`, updates are manual.
- The init container treats Grocy's security settings (`AUTH_CLASS`, `DISABLE_AUTH`, `MODE`, reverse proxy and LDAP) as chart-owned: it removes persisted `settingoverrides` for them and refuses to start unless the effective configuration is default authentication, production mode and authentication enabled. It runs with `DAC_OVERRIDE` only.
- `extraEnv` rejects `GROCY_*` and `FILE__*` names; `/config/php` is a read-only chart-owned ConfigMap (default `www2.conf`, `php-local.ini`) shadowing the volume.
- Grocy's default `admin`/`admin` is replaced by a generated password (by Secret reference) in an init container, after migrating the database and before the first request is served.
- The REST API (`/api/*`) skips the Emporium login; it uses Grocy's session or API keys.
- Tested on Emporium 0.5.0-rc.12 (2026-10-22): install, Emporium login then Grocy login with the generated password, default admin/admin rejected, REST API reachable with a Grocy API key without the Emporium login, uninstall without leftovers.
