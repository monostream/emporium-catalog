# drawio 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None. The chart had no inputs and has none now.

Removed values: `autoscaling.*` together with the HPA template. The `drawio.*` values (Google,
Microsoft Graph, GitLab, cloud convert integrations; secrets referenced by Secret name) are unchanged.

## Database

None. Diagrams are stored in the browser or in the user's own cloud storage.

## Data volumes

None. Nothing to keep before uninstalling a 0.4 install.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent: `<release>-tls` in perHost
mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

None in values. The optional `drawio.*Secret` values stay Secret names (key `key`).

## Behaviour changes

- drawio 32.5.5 (was 32.2.0).
- `DRAWIO_BASE_URL` is `https://<hostname>` (was empty, so the image used `http://localhost:8080`).
- CSP moved into `values.yaml`; `panel.appstore.launchpad.monocloud.io` (Emporium 0.4 panel) removed.
- Access default `authenticated`; choose `public` in Emporium for an open instance.
- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations.
- Runs as UID 1001 / GID 999 with all capabilities dropped; requests 50m CPU / 256Mi, memory limit 768Mi.
