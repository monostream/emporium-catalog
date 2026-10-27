# 0.1.3

Published on 27 October 2026

- uptime-kuma from 2.5.7 to 2.5.8

# 0.1.2

Published on 23 October 2026

- uptime-kuma from 2.5.6 to 2.5.7

# 0.1.1

Published on 22 October 2026

- uptime-kuma from 2.5.5 to 2.5.6

# 0.1.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; the TLS secret follows the zone's TLS mode.
- Data volume is the `data` storage integration (10Gi default, grow-only) instead of a StatefulSet volumeClaimTemplate, so the uninstall keep/delete choice applies.
- Push monitor URLs (`/api/push/*`) skip the Emporium login.
- Default resources (50m CPU / 192Mi requested, 512Mi limit) instead of none.

# 0.0.25

Published on 19 October 2026

- Removed nginx-only ingress class annotation and server-snippets

# 0.0.23

Published on 7 October 2026

- uptime-kuma from 2.0.1 to 2.5.5

# 0.0.22

Published on 20 October 2025

- uptime-kuma from 2.0.0-beta.0 to 2.0.1

# 0.0.21

Published on 2 December 2024

- uptime-kuma from 1.23.15 to 2.0.0-beta.0

# 0.0.20

Published on 1 October 2024

- uptime-kuma from 1.23.13 to 1.23.15

# Updates Thursday, 25-Apr-2024 08:02:32 UTC
- louislam/uptime-kuma from 1.23.12 to 1.23.13

# Updates Friday, 19-Apr-2024 08:03:17 UTC
- louislam/uptime-kuma from 1.23.11 to 1.23.12

