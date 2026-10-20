# jenkins 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

| Old key | New key | Note |
|---|---|---|
| `ControllerConfigSize` | deleted | `home` storage integration (JENKINS_HOME, default 5Gi, grow-only). |
| `ControllerWorkspaceSize` | deleted | `workspace` storage integration (default 50Gi, grow-only). |
| `AgentWorspaceSize` | `AgentWorkspaceSize` | `renamedFrom` carries the stored value. installOnly. |
| `AgentDinDSize` | `AgentDinDSize` | Unchanged key; installOnly. |

New inputs: `AdminPassword` (generated secret), `ClusterAdmin` (default `true`).

## Database

None (Jenkins keeps its state in JENKINS_HOME).

## Volumes (keep them before uninstalling 0.4)

- Controller: `<fullname>` (JENKINS_HOME) and `<fullname>-workspace`, created by the chart
  **without** `helm.sh/resource-policy: keep`. With `nameOverride` = app name, `<fullname>` is the
  release name. Before uninstalling a 0.4 release, annotate both:
  `kubectl -n <ns> annotate pvc <fullname> <fullname>-workspace helm.sh/resource-policy=keep`.
  Then move the instance with the installed-app blueprint
  (`docs/blueprints/migrate-installed-app-to-v0.5.md`) and choose them as existing claims for
  `home` and `workspace`.
- Agents: `data-<fullname>-agent-N` and `docker-<fullname>-agent-N` come from StatefulSet volume
  templates; Helm never deletes them. A reinstall under the same name reuses them.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent: `<release>-tls` in
perHost mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

- `ADMIN_PASSWORD`: `<app>-emporium-secrets` (generated). The admin user is only created when it
  does not exist yet, so a migrated JENKINS_HOME keeps its old admin password (the 0.4 chart used
  one hard-coded value for every install). With OIDC configured the local login is disabled; if
  OIDC is ever removed, change that password first.
- OIDC client secret: `<app>-emporium-secrets`, key `oidc.oidc.clientSecret` (was plaintext in the
  chart's own Secret).
- No plaintext secrets in values.

## Cluster-scoped objects and privileges

- `ClusterAdmin: true` renders a ClusterRoleBinding `<namespace>:<sa>-cluster-admin` to
  `cluster-admin` (namespaced name, no collision between instances). `false` gives the namespace
  `admin` role, which is enough for the launcher to scale the agent StatefulSet.
- The agent's Docker-in-Docker container is `privileged: true` and mounts `/lib/modules` from the
  host; namespaces enforcing the `baseline`/`restricted` Pod Security level reject it.

## Images

`monostream/devcloud-jenkins` and `-agent` stay at 2.479.2: there is no newer image, and their
sources are archived (`monostream/devcloud` `helpers/_archive/devcloud-jenkins*.zip`).

## Behaviour changes

- `BASE_URL` is `https://<host>/` (was the bare hostname).
- No `rollme` label: Jenkins restarts on upgrade only when the pod spec changes.
- The HPA pointing at `junkins-agent` is gone (it never matched anything).
- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations, and
  `oidcRedirectPaths` left `Chart.yaml`.
