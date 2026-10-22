# 0.1.1

Published on 22 October 2026

- Image repository is written without the `docker.io/` prefix (same image, Docker Hub is the default registry) so `emporium chart updates` can track the upstream releases; no change in behavior.

# 0.1.0

- New chart: Collabora Online Development Edition (CODE) 26.04.5.1.1, official `collabora/code` image (MPL-2.0), requires Emporium v0.5.0.
- WOPI host allowlist: every app below the Emporium zone by default, plus an input for additional hosts.
- Public ingress with long websocket timeouts (no proxy-body-size annotation: it makes the gateway reject websocket upgrades); admin console login generated and delivered by reference.
- Fail-closed WOPI allowlist: groups mode is set explicitly, the zone expression is URI compatible, and an empty list renders a group that matches nothing. MKNOD capability dropped.
