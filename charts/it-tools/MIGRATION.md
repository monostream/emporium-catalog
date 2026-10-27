# it-tools 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None. The chart had no inputs and has none now.

Removed values: `autoscaling.*` (no HPA template existed).

## Database

None. IT-Tools runs entirely in the browser; nothing is stored server-side.

## Data volumes

None. Nothing to keep before uninstalling a 0.4 install.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent: `<release>-tls` in perHost
mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

None.

## Behaviour changes

- Access default `authenticated`; choose `public` in Emporium for an open instance.
- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations.
- Image tag pinned in `values.yaml` (was the chart appVersion with `pullPolicy: Always`); same release.
- Read-only root filesystem, capabilities limited to CHOWN, SETUID, SETGID and NET_BIND_SERVICE
  (stock nginx starts as root on port 80).
- Rolling updates (was `Recreate`); requests 10m CPU / 32Mi, memory limit 128Mi.
