# 0.2.1
- Add emporium.build/tested annotation (passed real install on Emporium 0.5.0-rc.4, 2026-10-20).

# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; the TLS secret follows the zone's TLS mode. Default access is `authenticated`.
- No inputs (there were none before).
- Image pinned by digest (`excalidraw/excalidraw:latest` as of 2026-05-06; upstream publishes no version tags) with `pullPolicy: IfNotPresent`; appVersion `2026-05-06`.
- Default resources (10m CPU / 32Mi requested, 128Mi limit) and a `small` profile; replicas are editable (1-3).
- Read-only root filesystem with emptyDirs for nginx (`/tmp`, `/var/cache/nginx`, `/run`), only the capabilities nginx needs.
- Removed the HPA template, the autoscaling values and the `helm test` pod (unpinned busybox, no resources).
