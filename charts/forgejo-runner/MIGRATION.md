# forgejo-runner 0.0.x -> 0.1.0 (Emporium 0.5)

## Removed and renamed inputs

- `ForgejoURL`, `RunnerName`: same keys, now install-only (the runner registers once; a later
  change had no effect before either). `ForgejoURL` must start with `http://` or `https://`.
- `Token`: same key, now `type: secret`, delivered by reference (`<app>-emporium-secrets`, key
  `Token`, read by the registration hook through `secretKeyRef`).
- `RunnerCount`: same key, 1..20, default 1.

## Database

None.

## Hostnames

None (no ingress: the runner only talks outbound to Forgejo).

## TLS secret

None.

## Secrets

- Registration token: `<app>-emporium-secrets`, key `Token` (0.0.x put it into the hook Secret
  `<release>-forgejo-runner-config-generate` from plain values).
- Runner registration (`.runner`): still in `<release>-forgejo-runner-config`, created by the
  pre-install hook with `helm.sh/resource-policy: keep`, so it survives the uninstall of a 0.4
  install. A reinstall under the same release name in the same namespace reuses it and does not
  register again. Delete the Secret (and the runner in Forgejo) to register from scratch.

## Data to keep before uninstalling a 0.4 install

Nothing besides the `-config` Secret above, which Helm already keeps. Runner and Docker data are
`emptyDir`.

## Behaviour changes

- forgejo runner 13.2.0 (from 3.3.0). `register` is deprecated upstream but still works; the
  daemon reads `.runner` from its working directory (`--config /data/.runner` removed: it passed
  the registration file as the configuration file).
- Docker image `docker:29.9.2-dind` (0.0.70 used `docker:29.8.2`, which has no dockerd).
- The dockerd socket belongs to group 1000 (the runner image's group; was 0), and only the dind
  container is privileged.
- Hook: `registry.k8s.io/kubectl:v1.37.1` applies the generated Secret (`kubectl apply
  --server-side`); `docker.io/bitnami/kubectl` no longer pulls.
