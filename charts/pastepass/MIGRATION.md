# pastepass 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

`AppName` kept (now with the visible default `Pastepass`).

## Database

Not replaced. Pastepass keeps its BoltDB file (`/data/pastepass.boltdb`) on the data volume.

## Data volumes

- `data` (storage integration, default 1Gi, grow-only; the 0.4 claim key was `Workspace`),
  mounted at `/data`. Existing installs are moved with the installed-app blueprint
  (`docs/blueprints/migrate-installed-app-to-v0.5.md`) by choosing the old claim as existing claim.
- No Helm-managed claim to protect: under Emporium 0.4 the claim came from the old storage
  integration (`existingClaim` was always set), so the chart never rendered its own PVC and the
  upgrade does not delete anything.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

None.

## Behaviour changes

- Default volume size 10Gi -> 1Gi (pastes are small and expire).
- No `kubernetes.io/tls-acme` annotation from the chart.
