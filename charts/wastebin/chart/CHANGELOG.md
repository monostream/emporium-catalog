# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Image pinned to `quxfoo/wastebin:3.9.0` instead of `latest`; appVersion 3.9.0.
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; the TLS secret follows the zone's TLS mode.
- Data volume is the `data` storage integration (1Gi default, grow-only); the input "Storage Size" is removed.
- Cookie signing key and password salt are generated at install and read from the per-app Secret, so delete links survive restarts.
- Theme is a list (adds `rosepine`); the dead `WASTEBIN_ADDRESS` variable is gone.
- Read-only root filesystem with an emptyDir `/tmp` for SQLite (the image is `FROM scratch`); `Recreate` rollout so two pods never share the SQLite file.
- Default resources (20m CPU / 32Mi requested, 128Mi limit).

# 0.1.1

Published on 19 October 2026

- Chart renders again: add the missing _helpers.tpl, ServiceAccount and data PersistentVolumeClaim templates
- Resources from values.emporium.yaml apply (they were nested under the wastebin key the templates do not read)
