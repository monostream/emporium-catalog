# 0.1.0

- New chart: Grist 1.7.21 (grist-core, official image `gristlabs/grist`), requires Emporium v0.5.0.
- Single sign-on through Emporium (`sso` OIDC integration); ID tokens are accepted as ES384; accounts are identified by email.
- Optional installation administrator by email (`GRIST_ADMIN_EMAIL`); generated session secret and boot key delivered by reference.
- Formula sandbox Pyodide by default (unprivileged); telemetry and version check off.
- Home database (SQLite) and documents on one persistent volume.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, SSO login for an administrator and a plain user (accounts created, administrator mapped by email), user without email refused, boot-key API access, formulas in the Pyodide sandbox, uninstall without leftovers.
- Administrator email is required; the chart never leaves `GRIST_ADMIN_EMAIL` unset (Grist would otherwise make its support account administrator) and uses a non-routable placeholder when the value is empty.
