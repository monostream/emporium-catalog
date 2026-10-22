# 0.1.0

- New chart: Kanboard 1.2.56 (official image `kanboard/kanboard`, MIT), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG); attachments on a storage volume.
- Behind the Emporium login (`access: authenticated`); Kanboard keeps its own accounts. Header (reverse proxy) login is not enabled.
- Kanboard's default `admin`/`admin` is replaced by a generated password (by Secret reference) in an init container before the first request is served.
- The JSON-RPC API (`/jsonrpc.php`) skips the Emporium login for apps and scripts that use Kanboard credentials.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, Emporium login then Kanboard login with the generated administrator password, default admin/admin rejected, pod restart keeps the password, uninstall without leftovers. No single sign-on (Kanboard core has none).
