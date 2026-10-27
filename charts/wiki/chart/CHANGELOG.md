# 0.2.3

Published on 27 October 2026

- wiki from 2.5.316 to 2.5.317

# 0.2.2

Published on 21 October 2026

- Category: Content (was CMS).

# 0.2.1
- Add emporium.build/tested annotation (passed real install on Emporium 0.5.0-rc.5, 2026-10-20).

# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Wiki.js pinned to 2.5.316 (was the floating `2` tag).
- PostgreSQL is the `postgres` integration (CloudNativePG, PostgreSQL 17, cluster `<release>-postgres` as in 0.1.0), TLS verified against the cluster CA. Coming from 0.0.x: Existing installs start with an empty database; the data in the PostgreSQL bundled with the Wiki.js chart is not migrated (see MIGRATION.md).
- Ingress host, TLS secret, annotations and ingress class come from the `web` ingress integration.
- Default resources (50m CPU / 256Mi requested, 1Gi limit) instead of none.

# 0.1.0

Published on 19 October 2026

- PostgreSQL is provided by Emporium's native Postgres integration (CloudNativePG, PostgreSQL 17) instead of the PostgreSQL StatefulSet bundled in the Wiki.js chart; the password comes from the CloudNativePG app secret. Requires Emporium v0.5.0. Existing data in the bundled database is not migrated.
- Wiki.js connects to PostgreSQL over TLS and verifies the server certificate and hostname against the CloudNativePG CA (<release>-postgres-ca)

# 0.0.14

Published on 7 October 2026

- wiki from 2.2.24 to 3.0.0

# 0.0.13

Published on 12 September 2025

- wiki from 2.2.23 to 2.2.24

# 0.0.12

Published on 8 April 2025

- wiki from 2.2.22 to 2.2.23

# 0.0.11

Published on 23 November 2024

- wiki from 2.2.21 to 2.2.22

# 0.0.10

Published on 26 June 2024

- wiki from 2.2.20 to 2.2.21

