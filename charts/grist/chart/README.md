# Grist

Grist is a modern relational spreadsheet: the flexibility of a spreadsheet with the structure of a database. Columns have types, tables link to each other, and formulas are written in Python.

## Features

- Spreadsheet interface on top of linked tables, with reference and choice columns, filters, sorting and summary tables
- Python formulas, plus charts, cards, calendars and custom widgets on the same data
- Fine-grained access rules per table, row and column, and shareable forms
- Import and export of CSV and Excel files, document history and snapshots
- REST API and webhooks for scripts and automation
- Single sign-on through Emporium: every Emporium user with an email address gets a personal site at the first sign-in

## Perfect for

Teams that keep inventories, project trackers, CRMs or small business data in spreadsheets and want something more reliable and shareable, on their own server.

## Good to know

- **Email is required.** Grist identifies people by email address. An Emporium user without an email address cannot sign in; ask an Emporium administrator to set it.
- **Administrator.** Grist has no role mapping from the identity provider. "Administrator email" is required at install (without it Grist would make its built-in support account the administrator): the user who signs in with that email becomes the installation administrator (Admin Panel). Emporium administrators are otherwise regular users.
- **Break-glass.** Grist has no local passwords. The generated boot key (in the app's Secret, key `BootKey`) signs in as the administrator at `/boot` (with the administrator email), or authenticates API calls as the administrator when sent as the `x-boot-key` header. Grist itself prints the boot key in its startup log (upstream behaviour; the chart never logs it and delivers it only by Secret reference), so treat pod logs as sensitive.
- **Formula sandbox.** Spreadsheet formulas are code written by users. The default sandbox is Pyodide (Python in WebAssembly): it needs no privileges, so the pod stays unprivileged with a read-only root filesystem, but it is a lighter isolation than gVisor, which needs an unconfined pod and is not offered. Choosing "unsandboxed" runs formulas with the rights of the Grist process; do that only when every user is trusted.
- **Storage.** The home database (SQLite) and the documents live on one volume at `/persist`. Grist runs as a single replica; Redis is only needed for multi-server deployments and is not used.
- **No telemetry, no update check.** Both are switched off.
- The REST API (`/api`, `/o/<site>/api`) is reachable without the Emporium login and uses Grist API keys. Signing out of Grist keeps the Emporium session.
