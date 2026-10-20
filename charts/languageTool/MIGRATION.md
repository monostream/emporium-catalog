# languagetool 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None. The chart had no inputs and has none now.

Removed values: `autoscaling.*` (no HPA template existed). New value: `env` (map of container
environment variables, default `Java_Xms: 256m`, `Java_Xmx: 512m`, the image defaults).

## Database

None. LanguageTool is a stateless HTTP API (no n-gram data volume).

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

- Image tag pinned (was the chart appVersion with `pullPolicy: Always`); same release, 6.8.
- Access default `authenticated`; choose `public` in Emporium for an open instance. Browser add-ons
  and editor plugins cannot pass the Emporium login: choose `public` for those clients.
- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations.
- Requests 100m CPU / 768Mi, memory limit 1536Mi (none before), heap coupled in the `small` profile.
- UID 100, read-only root filesystem, all capabilities dropped; rolling updates (was `Recreate`).
