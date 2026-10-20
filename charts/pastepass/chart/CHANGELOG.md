# 0.2.1

Published on 20 October 2026

- Smaller gallery screenshots (re-encoded, max width 1600 px) so the packaged chart fits the Helm release record.

# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; the TLS secret follows the zone's TLS mode.
- Data volume is the `data` storage integration (1Gi default, grow-only; was 10Gi), so the uninstall keep/delete choice applies.
- Default resources (10m CPU / 32Mi requested, 128Mi limit) instead of none.
