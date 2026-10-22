# 0.3.1
- Add emporium.build/tested annotation (passed real install on Emporium 0.5.0-rc.5, 2026-10-20).

# 0.3.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- documenso from v2.19.0 to v2.21.0
- PostgreSQL is the `postgres` integration (CloudNativePG, PostgreSQL 17, cluster `<release>-postgres` as in 0.2.0), connected with `sslmode=require`. Coming from 0.1.x: Existing installs start with an empty database; the data in the old bundled Bitnami database is not migrated (see MIGRATION.md).
- Session and encryption keys are generated once at install into the per-app Secret (`NEXTAUTH_SECRET`, `NEXT_PRIVATE_ENCRYPTION_KEY`, `NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY`) instead of `lookup` helpers.
- New optional signing certificate inputs (base64 .p12 and passphrase); without a certificate Documenso cannot sign documents.
- SMTP password and OIDC client secret are read from Secrets by reference instead of plaintext values.
- Removed the unused data volume (Documenso keeps uploads in the database).
- Ingress host, TLS secret, annotations and ingress class come from the `web` ingress integration.
- Default resources (100m CPU / 384Mi requested, 1Gi limit) and health probes on `/api/health` with a startup probe for the migrations.

# 0.2.0

Published on 19 October 2026

- PostgreSQL is provided by Emporium's native Postgres integration (CloudNativePG, PostgreSQL 17) instead of the bundled Bitnami postgresql subchart. The app reads its connection URI from the CloudNativePG app secret. Requires Emporium v0.5.0. Existing data in the bundled database is not migrated.
- The secondary encryption key is looked up in its own Secret, so it no longer changes on every upgrade

# 0.1.19

Published on 7 October 2026

- documenso from v1.12.1 to v2.19.0
- postgresql from 16.7.26 to 16.7.27

# 0.1.16

Published on 3 July 2025

- documenso from v1.11.1 to v1.12.1

# 0.1.15

Published on 21 May 2025

- documenso from v1.11.0 to v1.11.1

# 0.1.14

Published on 19 May 2025

- documenso from v1.10.3 to v1.11.0

# 0.1.13

Published on 3 May 2025

- documenso from v1.8.1 to v1.10.3

# 0.1.12

Published on 23 February 2025

- documenso from v1.8.1-rc.2 to v1.8.1

# 0.1.11

Published on 29 November 2024

- documenso from v1.8.1-rc.1 to v1.8.1-rc.2

# 0.1.10

Published on 26 November 2024

- documenso from v1.8.1-rc.0 to v1.8.1-rc.1

# 0.1.9

Published on 20 November 2024

- documenso from v1.8.0-rc.4 to v1.8.1-rc.0

# 0.1.8

Published on 19 November 2024

- documenso from v1.8.0-rc.3 to v1.8.0-rc.4

# 0.1.7

Published on 16 November 2024

- documenso from v1.8.0-rc.2 to v1.8.0-rc.3

# 0.1.6

Published on 14 November 2024

- documenso from v1.8.0-rc.1 to v1.8.0-rc.2

# 0.1.5

Published on 12 November 2024

- documenso from v1.7.2-rc.4 to v1.8.0-rc.1

# 0.1.4

Published on 8 November 2024

- documenso from v1.7.0 to v1.7.2-rc.4

