# 0.2.1

Published on 22 October 2026

- The app image repository is set explicitly in the values (same image as before) so `emporium chart updates` can resolve and bump it.

# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- PostgreSQL is Emporium's `db` postgres integration (CloudNativePG cluster `<release>-db`, PostgreSQL 17, sslmode require) instead of the bundled Bitnami postgresql subchart (PostgreSQL 11, password `porter`, image no longer pullable). Existing installs start with an empty database.
- Fixed: the image tag `v0.53.0` that the porter chart pins was never published; the chart now uses `porter1/porter:v0.52.56`, the last self-hosted release.
- The cookie, database encryption and token keys are generated at install instead of the upstream chart's well-known defaults. The upstream chart only accepts them, and the database password, as plain values (acknowledged lint warnings).
- The chart renders its own Ingress (host, TLS secret, ingress class and annotations from the `web` ingress integration). The upstream Ingress had no ingress class and made the pod mount a hard-coded `porter-cert-tls` Secret.
- Default resources without a CPU limit (requests 100m/256Mi, memory limit 512Mi); profile small.

# 0.1.32

Published on 19 October 2026

- Ingress path is set (the porter chart reads hosts[].path; the paths list was ignored and the rule had an empty path)

# Updates Wednesday, 05-Jun-2024 08:01:40 UTC
- porter from 0.189.0 to 0.190.0

# Updates Thursday, 23-May-2024 17:02:32 UTC
- porter from 0.188.0 to 0.189.0

# Updates Wednesday, 22-May-2024 17:03:12 UTC
- porter from 0.187.0 to 0.188.0

# Updates Tuesday, 21-May-2024 08:01:30 UTC
- porter from 0.186.0 to 0.187.0

# Updates Friday, 17-May-2024 08:02:07 UTC
- porter from 0.185.0 to 0.186.0

# Updates Wednesday, 17-Apr-2024 08:01:10 UTC
- porter from 0.183.0 to 0.185.0

# Updates Tuesday, 16-Apr-2024 08:03:17 UTC
- porter from 0.182.0 to 0.183.0

