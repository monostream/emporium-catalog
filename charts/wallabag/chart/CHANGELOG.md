# 0.1.0

- New chart: Wallabag 2.6.14 (official image `wallabag/wallabag`, MIT), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG), connection by reference, `sslmode=require`.
- No native single sign-on in Wallabag 2.6: the chart is protected by the Emporium login (`access: authenticated`) and Wallabag keeps its own accounts.
- A setup init container creates the schema and the local administrator (generated password in the per-app Secret) before Wallabag serves its first request; the built-in `wallabag`/`wallabag` account is never created. Public registration is off.
- `/api/*`, `/oauth/v2/token` and `/feed/*` skip the Emporium login so mobile apps, browser extensions and feed readers work with their own OAuth tokens and feed tokens.
- Encryption key and downloaded images on a volume (`data` storage integration).
- Not included: the Redis/RabbitMQ import workers and outgoing mail.
- Tested on Emporium 0.5.0-rc.12 (2026-10-22, run 447280): install, local administrator login, default wallabag/wallabag refused, OAuth token and API with bearer, skip paths, uninstall without leftovers.
- Setup init container: the default-account check now runs before every successful exit (existing installs too), and an interrupted install is completed without a schema reset. README: API registration is PUT /api/user, token endpoint throttling documented as a known limitation.
