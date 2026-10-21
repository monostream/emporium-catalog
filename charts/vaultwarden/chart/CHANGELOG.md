# 0.3.0
- Single sign-on through Emporium (OpenID Connect, `sso` integration): the login page offers "Enterprise single sign-on". Password login stays available (`SSO_ONLY` off) and the master password is still required after an SSO login.
- `SSO_SIGNUPS_MATCH_EMAIL` is on: the first SSO login of an existing account with the same email links to it (only with a verified email at the provider).
- The callback `/identity/connect/oidc-signin` is registered as redirect path; `/identity/*` and `/api/*` still skip the Emporium login.

# 0.2.1
- Add emporium.build/tested annotation (passed real install on Emporium 0.5.0-rc.5, 2026-10-20).

# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; the TLS secret follows the zone's TLS mode.
- Data volume is the `data` storage integration (1Gi default, grow-only), so the uninstall keep/delete choice applies.
- Optional PostgreSQL through Emporium's postgres integration (CloudNativePG, PostgreSQL 17, `sslmode=require`), off by default; without it Vaultwarden keeps SQLite on the data volume.
- SMTP is optional; the SMTP password is read from the per-app Secret instead of plain values.
- New input "Allow sign-ups" (default on). Fixed: `SIGNUPS_ALLOWED` was set to the domain.
- Bitwarden client APIs (`/api/*`, `/identity/*`) skip the Emporium login; the meaningless `/#/*` skip path is gone.
- Default resources (50m CPU / 128Mi requested, 256Mi limit) instead of none.

# 0.1.19

Published on 7 October 2026

- server from 1.35.2 to 1.37.4

# 0.1.18

Published on 10 January 2026

- server from 1.35.1 to 1.35.2

# 0.1.17

Published on 30 December 2025

- server from 1.35.0 to 1.35.1

# 0.1.16

Published on 28 December 2025

- server from 1.34.3 to 1.35.0

# 0.1.15

Published on 30 July 2025

- server from 1.34.2 to 1.34.3

# 0.1.14

Published on 28 July 2025

- server from 1.34.1 to 1.34.2

# 0.1.13

Published on 27 May 2025

- server from 1.33.2 to 1.34.1

# 0.1.12

Published on 10 February 2025

- server from 1.33.1 to 1.33.2

# 0.1.11

Published on 3 February 2025

- server from 1.33.0 to 1.33.1

# 0.1.10

Published on 25 January 2025

- server from 1.32.7 to 1.33.0

# 0.1.9

Published on 20 December 2024

- server from 1.32.6 to 1.32.7

# 0.1.8

Published on 11 December 2024

- server from 1.32.5 to 1.32.6

# 0.1.7

Published on 18 November 2024

- server from 1.32.4 to 1.32.5

# 0.1.6

Published on 11 November 2024

- server from 1.32.3 to 1.32.4

