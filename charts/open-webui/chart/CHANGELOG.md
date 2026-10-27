# 0.1.2

Published on 27 October 2026

- open-webui from v0.12.3 to 0.12.4

# 0.1.1

- Users whose token carries no roles claim are created as `pending` (fail closed) instead of regular users; README explains revocation.
- Document that the Ollama URL input only seeds the first start (Open WebUI persists connection settings).
- Re-tested on Emporium 0.5.0-rc.12 (2026-10-21), including a user without any Emporium role.

# 0.1.0

- New chart: Open WebUI v0.12.3 (official image `ghcr.io/open-webui/open-webui`), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG); uploads and caches on a `data` volume.
- Single sign-on through Emporium (`sso` OIDC integration, "Continue with Emporium") with role mapping from the `roles` claim (`emporium-admin` becomes administrator, `emporium-user` a regular user).
- Optional Ollama connection through the "Ollama URL" input.
- Local administrator created at the first start; password generated into the per-app Secret.
- `/api`, `/openai` and `/ollama` skip the Emporium login so API clients work.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, SSO login as administrator and as plain user (role mapping, users without email), local administrator login, uninstall without leftovers.
