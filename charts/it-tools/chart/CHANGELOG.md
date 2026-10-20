# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; the TLS secret follows the zone's TLS mode. Default access is `authenticated`.
- No inputs (there were none before).
- Image pinned to `corentinth/it-tools:2024.10.22-7ca5933` (the latest release) with `pullPolicy: IfNotPresent`.
- Default resources (10m CPU / 32Mi requested, 128Mi limit) and a `small` profile; replicas are editable (1-3).
- Read-only root filesystem with emptyDirs for nginx (`/tmp`, `/var/cache/nginx`, `/run`), only the capabilities nginx needs.
- Rolling updates instead of `Recreate`; the unused autoscaling values are gone.

# 0.1.6

Published on 19 October 2026

- Respect the access policy chosen in Emporium; the chart no longer forces public access. Choose 'Public' in Emporium to keep the previous behaviour.

# 0.1.5

Published on 22 October 2024

- it-tools from 2024.5.13-a0bc346 to 2024.10.22-7ca5933

# Updates Monday, 13-May-2024 17:02:47 UTC
- corentinth/it-tools from 2024.5.10-33e5294 to 2024.5.13-a0bc346

# Updates Friday, 10-May-2024 17:03:00 UTC
- corentinth/it-tools from 2023.12.21-5ed3693 to 2024.5.10-33e5294

