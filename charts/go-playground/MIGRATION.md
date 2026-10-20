# go-playground 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None. The chart had no inputs and has none now.

Values: `deployment.replicaCount` -> `replicaCount`; removed `app.name`, `autoscaling.*` (no HPA
template existed) and the `PORT` environment variable (the image always listens on 8000).

## Database

None. Snippets are shared through the upstream Go playground; nothing is stored in the cluster.

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

- Go Playground 3.0.0 (was 2.5.7), image tag pinned (was the chart appVersion with `pullPolicy: Always`).
- The ingress sets `ingressClassName` from the integration.
- Access default `authenticated`; choose `public` in Emporium for an open instance.
- The chart no longer writes `emporium.build/auth-*`, `kubernetes.io/tls-acme` or the
  `proxy-*` annotations (body size and read timeout were the defaults' order of magnitude; send
  timeout is not supported by Emporium).
- Requests 50m CPU / 128Mi (was 250m / 256Mi), memory limit 512Mi, CPU limit removed.
- `deps.json` follows `image.tag` (it pointed at a dependency the chart does not have).
