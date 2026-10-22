# Kanboard

Kanboard is a lean kanban board for project management: visualize work in columns, limit work in progress and see who does what, without a heavy tool.

Kanboard (MIT) was chosen over Planka (source-available licence), Wekan (MongoDB only) and Focalboard (no release since 2024).

## Features

- Kanban boards with columns, swimlanes, work-in-progress limits, colors, categories and tags
- Tasks with subtasks, comments, attachments, due dates, time tracking and internal or external links
- Automatic actions (move, assign, close, create tasks from events), filters, a calendar and analytics
- Several projects with their own members and roles, plus a JSON-RPC API for scripts and integrations
- Your data stays on your own PostgreSQL database and storage volume

## Perfect for

Small teams and households who want a simple, fast board for their projects and are happy to manage it themselves.

## Good to know

- Kanboard sits behind the Emporium login. Kanboard keeps its own accounts and shows its own login page after it: sign in as `admin` (the local administrator) and create accounts for other people under Settings > Users. Kanboard has no native OpenID Connect (only third-party plugins), so Emporium identities are not mapped to Kanboard users.
- Kanboard creates the account `admin` with the password `admin` when it sets up an empty database. This chart replaces that password with a generated one (in the app's Secret, or the one you enter at install) in an init container before Kanboard serves its first request. Change it under your profile if you like; it is not reset on restart.
- Header (reverse proxy) login is not enabled: Kanboard would trust a user name sent by the proxy, and nothing in the chart guarantees that client-supplied copies of such headers are stripped before they reach it.
- The JSON-RPC API (`/jsonrpc.php`, used by apps, scripts and integrations) skips the Emporium login and requires a Kanboard user password or the application API token.
- The connection to PostgreSQL is encrypted and the server certificate is verified against the database's CA (`PGSSLMODE=verify-full`).
- Uploads up to 32 MiB are allowed through the ingress (Kanboard's own limit).
- The JSON-RPC API is reachable without the Emporium login. Passwords are protected by Kanboard's account lockout, but guessing the application API token is not rate limited: if the API is not needed, put a rate limit or an IP allowlist on the host.
- Kanboard blocks an account for a while after repeated failed sign-ins.
- The container image starts as root (nginx, cron and PHP-FPM are supervised by s6, nginx and PHP then run as the `nginx` user), so the pod does not run as non-root and has a writable root filesystem. All capabilities are dropped except the few it needs.
- Plugins cannot be installed from the web UI (the plugin installer is disabled upstream by default); the plugins directory is not persistent.
