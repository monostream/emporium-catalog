# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; the TLS secret follows the zone's TLS mode. Default access is `authenticated`.
- No inputs (there were none before).
- Image tag 6.8 pinned in `values.yaml` with `pullPolicy: IfNotPresent`.
- `small` profile couples the JVM heap (`Java_Xmx` 512m) with the container memory (768Mi requested, 1536Mi limit, 100m CPU); replicas are editable (1-3).
- New `env` map for the container (JVM heap, `langtool_*` settings).
- Runs as the image's languagetool user (UID 100) with a read-only root filesystem and an emptyDir at `/tmp`; the liveness probe waits 20s for the JVM.
- Rolling updates instead of `Recreate`; the unused autoscaling values are gone.

# 0.1.17

Published on 19 October 2026

- Respect the access policy chosen in Emporium; the chart no longer forces public access. Choose 'Public' in Emporium to keep the previous behaviour.

# 0.1.15

Published on 6 October 2026

- languagetool from 6.6 to 6.8

# 0.1.14

Published on 28 May 2025

- languagetool from 6.6-dockerupdate-1 to 6.6

# 0.1.12

Published on 17 May 2025

- languagetool from 6.5 to 6.6

# 0.1.11

Published on 1 October 2024

- languagetool from 6.4 to 6.5

# Updates Wednesday, 01-May-2024 17:01:57 UTC
- erikvl87/languagetool from 6.3 to 6.4

