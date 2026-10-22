# 0.1.0

- New chart: Etherpad 3.3.9 (official image `etherpad/etherpad`), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG).
- Access through the Emporium login; Etherpad itself has no generic OpenID Connect client without a plugin, and plugins are installed into the image at build time, so there is no `oidc` integration.
- `/admin` for settings and pad management with the user `admin`; the password is generated into the per-app Secret unless set at install. The client secrets of Etherpad's built-in sign-in service are generated too (the upstream defaults are well known).
- The database connection uses TLS and verifies the server certificate (`verify-full`) against the CloudNativePG CA.
- README no longer claims OpenDocument (no LibreOffice in the image).
- In-app update notifications are off (Emporium manages versions).
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, Emporium login, live editing from two clients over WebSocket, /admin login, pads stored in PostgreSQL, uninstall without leftovers.
