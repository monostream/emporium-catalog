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
- **Why a live annotation is not enough:** `kubectl annotate` on the claim protects a
  `helm upgrade`, but `helm uninstall` decides from the manifest stored in the release, which has no
  keep annotation. The 0.5 path for an installed 0.4 app is uninstall + reinstall (installed-app
  blueprint, `docs/blueprints/migrate-installed-app-to-v0.5.md`; `updateApp` refuses
  `NEEDS_MIGRATION` apps), so the keep annotation has to be in the stored manifest first.
- **Before uninstalling (preferred):** upgrade the release once more with the **old** chart version
  and the annotation in the values (the old chart passes `ollama.persistentVolume.annotations` through), then check the
  stored manifest:

  ```bash
  helm -n <ns> upgrade <release> <catalog-repo>/ollama --version 0.1.106 --reuse-values \
    --set-string 'ollama.persistentVolume.annotations.helm\.sh/resource-policy=keep'
  helm -n <ns> get manifest <release> | grep -A6 'kind: PersistentVolumeClaim'   # must show resource-policy: keep
  ```

- **If that upgrade is not possible** (old chart version unavailable, release broken): back the
  data up, then take the volume out of Helm's hands before uninstalling: set the bound PV to
  `Retain`, let the uninstall delete the claim, then clear the PV's `claimRef` and bind a new claim
  named `ollama` to it with `spec.volumeName`:

  ```bash
  PV=$(kubectl -n <ns> get pvc ollama -o jsonpath='{.spec.volumeName}')
  kubectl patch pv "$PV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
  # after the uninstall:
  kubectl patch pv "$PV" --type json -p '[{"op":"remove","path":"/spec/claimRef"}]'
  # create PVC ollama with spec.volumeName: $PV (same size/access mode/storageClassName), then
  # choose it as the existing claim of the data integration
  ```

- If neither is possible, the claim does not survive the uninstall: migrating this install to 0.5
  is unsupported without losing the volume (Emporium 0.5 cannot upgrade a 0.4 app in place).
- Then choose `ollama` as the existing claim of the `data` integration (Emporium never owns or
  deletes a claim chosen that way), or let the models download again (the simplest fallback:
  models are re-downloadable, nothing else lives on the volume).

## Hostnames

None: Ollama has no ingress (in-cluster API on port 11434).

## TLS secret

None.

## Secrets

None.

## Behaviour changes

- GPU vs CPU is the profile choice (`gpu` default keeps the old behaviour: `nvidia.com/gpu: 1`).
- `defaultModel` dropped (dead value; nothing was ever pulled at startup).
