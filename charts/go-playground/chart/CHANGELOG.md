# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Go Playground from 2.5.7 to 3.0.0 (CodeMirror editor, Go 1.26); the image tag is pinned in `values.yaml` with `pullPolicy: IfNotPresent`.
- Ingress host, TLS secret and ingress class come from the `web` ingress integration (the ingress had no class before); the TLS secret follows the zone's TLS mode. Default access is `authenticated`.
- No inputs (there were none before).
- Replicas move from `deployment.replicaCount` to `replicaCount` and are editable (1-3); `small` profile with 50m CPU / 128Mi requested and a 512Mi limit (no CPU limit).
- Dropped the dead `proxy-send-timeout`, the default `proxy-read-timeout` and the unused `proxy-body-size` annotations, the unused `PORT` variable and the unused `app.name` and autoscaling values.

# 0.1.5

Published on 19 October 2026

- Respect the access policy chosen in Emporium; the chart no longer forces public access. Choose 'Public' in Emporium to keep the previous behaviour.

