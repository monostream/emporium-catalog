# 0.2.2

Published on 27 October 2026

- Image 1.1.1: Node.js from Alpine's nodejs 20 (EOL) to 24.22.1, nginx 1.25.4 to 1.30.6 on Alpine 3.24 with brotli-libs 1.2.1 (CVE-2026-111497)
- The image source now lives in `build/` and is published by the Build VitePress workflow

# 0.2.1

Published on 21 October 2026

- Category: Content (was CMS).

# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Inputs `GitUrl`, `BasePath` and `PollInterval` keep their keys and now show their defaults (`https://github.com/monostream/emporium-docs.git`, `/docs`, 60 seconds); the poll interval is bounded to 10-86400 seconds.
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; the TLS secret follows the zone's TLS mode. Default access is `authenticated`.
- Image tag 1.1.0 pinned in `values.yaml` with `pullPolicy: IfNotPresent`.
- Default resources (100m CPU / 512Mi requested, 1536Mi limit for npm builds) and a `small` profile; replicas are editable (1-3).
- Probes: the pod is ready once the built site answers under the base path (the probes rendered as `null` before); liveness is a TCP check.
- Removed `test-values.yaml` (hard-coded host and `tls-acme`).
