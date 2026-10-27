# excalidraw 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None. The chart had no inputs and has none now.

Removed values: `autoscaling.*` together with the HPA template; the `helm test` connection pod.

## Database

None. Drawings live in the browser (local storage); live collaboration uses Excalidraw's public
collaboration server, as before.

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

- Image pinned by digest (`image.digest`, wins over `image.tag`); was `latest` with `pullPolicy: Always`.
  Upstream has no version tags, so a newer build needs a manual digest bump.
- Access default `authenticated`; choose `public` in Emporium for an open instance.
- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations.
- Read-only root filesystem, capabilities limited to CHOWN, SETUID, SETGID and NET_BIND_SERVICE
  (stock nginx starts as root on port 80).
- Requests 10m CPU / 32Mi, memory limit 128Mi.
