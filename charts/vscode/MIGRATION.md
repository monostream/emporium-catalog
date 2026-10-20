# vscode 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

| Old key | New key | Note |
|---|---|---|
| `StorageSize` | deleted | The `data` storage integration owns the home volume size (default 20Gi, grow-only). |
| `NvidiaEnabled` | `NvidiaEnabled` | Unchanged key; boolean with default `false`. |

New input `ClusterAdmin` (default `true`, the previous behaviour).

## Database

None.

## Home volume (keep it before uninstalling 0.4)

0.1.x created the claim `<fullname>` (the release name, or `<release>-vscode`) **without**
`helm.sh/resource-policy: keep`. Before uninstalling a 0.4 release, annotate it so it survives:
`kubectl -n <ns> annotate pvc <fullname> helm.sh/resource-policy=keep`.
Then move the instance with the installed-app blueprint
(`docs/blueprints/migrate-installed-app-to-v0.5.md`) and choose that claim as the existing claim.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent: `<release>-tls` in
perHost mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

None. code-server runs with `--auth none`; the Emporium login is the only protection. The
access default is now `admins` (was `authenticated`): only Emporium admins can open the IDE unless
the installer picks a wider access level. The unused `password` value is gone.

## Cluster-scoped objects and privileges

- `ClusterAdmin: true` renders a ClusterRoleBinding `<namespace>:<fullname>-cluster-admin` to
  `cluster-admin` (namespaced name, so several instances do not collide). Anyone who can open the
  IDE can administer the whole cluster. Set it to `false` for a namespace-only workspace.
- The Docker engine sidecar is `privileged: true`; namespaces that enforce the `restricted` or
  `baseline` Pod Security level reject the pod.

## Image

`emporium-apps.docker.pkg.emporium.rocks/vscode:4.140.0` is built by `.github/workflows/build.yml`
from `charts/vscode/build/` (tag = `CODE_SERVER_VERSION` in the Dockerfile, only on pushes to
`main` or `workflow_dispatch`). Unchanged in this release.

## Behaviour changes

- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations.
- Default resources for every container (they were empty).
