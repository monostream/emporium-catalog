# vitepress 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

| Old key | New key | Note |
|---|---|---|
| `GitUrl` | `GitUrl` | Unchanged key; now `required` with the visible default `https://github.com/monostream/emporium-docs.git`. |
| `BasePath` | `BasePath` | Unchanged key; default `/docs`, must start with `/`. Also sets the ingress path. |
| `PollInterval` | `PollInterval` | Unchanged key; integer, default 60, bounds 10-86400. |

Stored values carry over. An install that left a field empty now gets the default shown above,
which is what the image used for an empty field before.

## Database

None. The site is cloned and built into the container at start.

## Data volumes

None. Nothing to keep before uninstalling a 0.4 install.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent: `<release>-tls` in perHost
mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

None. Private repositories are not supported (as before).

## Behaviour changes

- Access default `authenticated`; choose `public` in Emporium for a public documentation site.
- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations.
- Image tag pinned (was the chart appVersion with `pullPolicy: Always`); same release, 1.1.0.
- Readiness waits for the first build (`GET <BasePath>/`), liveness is a TCP check on port 80.
- Requests 100m CPU / 512Mi, memory limit 1536Mi (none before).
