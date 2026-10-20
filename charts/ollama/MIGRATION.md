# ollama 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

- `StorageSize`: deleted; the size is the `data` storage integration's choice (default 30Gi,
  grow-only).
- `RuntimeClassName`: kept (now optional; empty means the cluster default).

## Database

None.

## Data volumes

- `data` (storage integration, default 30Gi, grow-only), mounted at `/root/.ollama` (downloaded
  models). 0.1.x let the upstream chart create and own the claim `ollama` (Helm-managed, no keep
  annotation). With `existingClaim` set the chart stops rendering it, so Helm **deletes** it on the
  upgrade, even when the same claim is chosen as the existing claim, and a `Delete` reclaim policy
  destroys the models.
- **Before the upgrade** (or before reinstalling with the installed-app blueprint,
  `docs/blueprints/migrate-installed-app-to-v0.5.md`), mark the claim as kept:

  ```bash
  kubectl -n <ns> annotate pvc ollama helm.sh/resource-policy=keep
  ```

  Then choose `ollama` as the existing claim of the `data` integration (Emporium never owns or
  deletes a claim chosen that way), or let the models download again.

## Hostnames

None: Ollama has no ingress (in-cluster API on port 11434).

## TLS secret

None.

## Secrets

None.

## Behaviour changes

- GPU vs CPU is the profile choice (`gpu` default keeps the old behaviour: `nvidia.com/gpu: 1`).
- `defaultModel` dropped (dead value; nothing was ever pulled at startup).
