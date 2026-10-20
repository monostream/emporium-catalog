# 0.2.1
- Add emporium.build/tested annotation (passed real install on Emporium 0.5.0-rc.5, 2026-10-20).

# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- n8n from 2.36.8 to 2.43.8 (image pinned in the chart; the 8gears chart 2.1.1 is still the latest).
- Optional PostgreSQL through Emporium's postgres integration (CloudNativePG, PostgreSQL 17, verified TLS against the cluster CA), off by default; without it n8n keeps SQLite on the data volume.
- Data volume is the `data` storage integration (8Gi default, grow-only); the input "Storage Size" is removed.
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; the TLS secret follows the zone's TLS mode.
- Webhook, form and MCP trigger endpoints skip the Emporium login so external systems can call them; the editor stays behind it.
- `WEBHOOK_URL`, `N8N_EDITOR_BASE_URL`, `N8N_HOST` and `N8N_PROXY_HOPS` are set, so webhook URLs shown in the editor use the public hostname.
- Default resources (100m CPU / 384Mi requested, 1Gi limit); container drops all capabilities.

# 0.1.37

Published on 19 October 2026

- Ingress paths use the object form (path, pathType) that n8n chart 2.x expects; the chart failed to render before
- Persistence moved to main.persistence (n8n chart 2.x); the StorageSize volume was not created and data lived in an emptyDir

# 0.1.35

Published on 7 October 2026

- n8n from 1.0.15 to 2.1.1

# 0.1.34

Published on 17 September 2025

- n8n from 1.0.14 to 1.0.15

# 0.1.33

Published on 3 September 2025

- n8n from 1.0.10 to 1.0.14

# 0.1.32

Published on 26 June 2025

- n8n from 1.0.9 to 1.0.10

# 0.1.31

Published on 25 June 2025

- n8n from 1.0.7 to 1.0.9

# 0.1.30

Published on 2 June 2025

- n8n from 1.0.6 to 1.0.7

# 0.1.29

Published on 31 March 2025

- n8n from 1.0.5 to 1.0.6

# 0.1.28

Published on 27 March 2025

- n8n from 1.0.4 to 1.0.5

# 0.1.27

Published on 4 March 2025

- n8n from 1.0.3 to 1.0.4

# 0.1.26

Published on 4 March 2025

- n8n from 1.0.2 to 1.0.3

# 0.1.25

Published on 3 March 2025

- n8n from 1.0.1 to 1.0.2

# 0.1.24

Published on 23 February 2025

- n8n from 0.25.2 to 1.0.1

# 0.1.23

Published on 14 September 2024

- n8n from 0.25.1 to 0.25.2

# 0.1.22

Published on 10 September 2024

- n8n from 0.25.0 to 0.25.1

# 0.1.21

Published on 23 August 2024

- n8n from 0.24.4 to 0.25.0

# 0.1.20

Published on 13 July 2024

- n8n from 0.24.3 to 0.24.4

# 0.1.19

Published on 12 July 2024

- n8n from 0.24.0 to 0.24.3

# 0.1.18

Published on 12 July 2024

- n8n from 0.23.1 to 0.24.0

# 0.1.17

- Update to n8n 1.34.2 ([release notes](https://docs.n8n.io/release-notes/#n8n1342))