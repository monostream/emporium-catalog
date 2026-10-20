# uptime-kuma 0.0.x -> 0.1.0 (Emporium 0.5)

## Removed and renamed inputs

None (the chart had no inputs).

## Database

Not replaced. Uptime Kuma keeps its SQLite database in `/app/data`.

## Data volumes

- `data` (storage integration, default 10Gi, grow-only), mounted at `/app/data`. 0.0.x used a
  StatefulSet volumeClaimTemplate; the claim is `<fullname>-pvc-<fullname>-0`, where `<fullname>`
  is the release name when it contains `uptime-kuma` (release `uptime-kuma` gives
  `uptime-kuma-pvc-uptime-kuma-0`) and `<release>-uptime-kuma` otherwise. Check the real name first:

  ```bash
  kubectl -n <ns> get pvc   # the template claim carries no instance label
  ```

- A StatefulSet's volumeClaimTemplates cannot change in place, so existing installs are moved with
  the installed-app blueprint (`docs/blueprints/migrate-installed-app-to-v0.5.md`): reinstall with
  that claim chosen as existing claim. The claim is owned by the StatefulSet controller, not Helm,
  so neither `helm uninstall` nor the upgrade deletes it (no keep annotation needed). Without
  Emporium the chart still uses the template.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

None.

## Behaviour changes

- Skip path `/api/push/*` so push monitors work while the UI stays behind the Emporium login.
- `kubernetes.io/tls-acme` removed from the default ingress annotations.
