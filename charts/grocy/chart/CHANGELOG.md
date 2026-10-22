# 0.1.0

- New chart: Grocy 4.7.1 (MIT), requires Emporium v0.5.0. Grocy publishes no container image, so the chart uses the linuxserver.io image `lscr.io/linuxserver/grocy`.
- SQLite database, uploads and `config.php` on one storage volume (`/config`); a single replica.
- Behind the Emporium login (`access: authenticated`); Grocy keeps its own accounts. Header (reverse proxy) login is not enabled.
- Grocy's default `admin`/`admin` is replaced by a generated password (by Secret reference) in an init container, after migrating the database and before the first request is served.
- The REST API (`/api/*`) skips the Emporium login; it uses Grocy's session or API keys.
- Tested on Emporium 0.5.0-rc.12 (2026-10-22): install, Emporium login then Grocy login with the generated password, default admin/admin rejected, REST API reachable with a Grocy API key without the Emporium login, uninstall without leftovers.
