# cyberchef 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None. The chart had no inputs and has none now.

Removed values: `autoscaling.*` (no HPA template existed).

## Database

None. CyberChef is a static web app; nothing is stored server-side.

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
- Hardened pod: UID 101, read-only root filesystem, all capabilities dropped, emptyDir at `/tmp`.
- Rolling updates (was `Recreate`); requests 10m CPU / 32Mi, memory limit 128Mi.
