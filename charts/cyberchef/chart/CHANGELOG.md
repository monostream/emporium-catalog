# 0.2.1
- Add emporium.build/tested annotation (passed real install on Emporium 0.5.0-rc.4, 2026-10-20).

# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Ingress host, TLS secret and ingress class come from the `web` ingress integration; the TLS secret follows the zone's TLS mode. Default access is `authenticated`.
- No inputs (there were none before).
- Default resources (10m CPU / 32Mi requested, 128Mi limit) and a `small` profile; replicas are editable (1-3).
- Runs as UID 101 with a read-only root filesystem, no capabilities and an emptyDir at `/tmp`; `pullPolicy: IfNotPresent` for the pinned 11.5.0 image.
- Rolling updates instead of `Recreate`; the unused autoscaling values are gone.

# 0.1.24

- Respect the access policy chosen in Emporium; the chart no longer forces public access. Choose 'Public' in Emporium to keep the previous behaviour.

# 0.1.23

- Fix CyberChef 11 HTTP container/probe port 8080 while preserving Service port80 and ingress/auth configuration.

# 0.1.22

Published on 6 October 2026

- cyberchef from 10.21 to 11.5.0

# 0.1.21

Published on 6 February 2026

- cyberchef from 10.20 to 10.21

# 0.1.20

Published on 28 January 2026

- cyberchef from 10.19.4 to 10.20

# 0.1.19

Published on 23 October 2024

- cyberchef from 10.19.2 to 10.19.4

# 0.1.18

Published on 15 August 2024

- cyberchef from 10.19 to 10.19.2

# 0.1.17

Published on 21 June 2024

- cyberchef from 10.18.8 to 10.19

# Updates Thursday, 13-Jun-2024 07:44:48 UTC
- https://ghcr.io/gchq/cyberchef from 10.18.6 to 10.18.8

# Updates Friday, 17-May-2024 08:02:16 UTC
- https://ghcr.io/gchq/cyberchef from 10.18.5 to 10.18.6

# Updates Thursday, 16-May-2024 17:02:32 UTC
- https://ghcr.io/gchq/cyberchef from 10.18.3 to 10.18.5

# Updates Thursday, 25-Apr-2024 08:01:21 UTC
- https://ghcr.io/gchq/cyberchef from 10.17 to 10.18.3

# Updates Sunday, 14-Apr-2024 08:17:55 UTC
- https://ghcr.io/gchq/cyberchef from 10.16 to 10.17

# Updates Friday, 12-Apr-2024 17:01:31 UTC
- https://ghcr.io/gchq/cyberchef from 10.15.1 to 10.16

