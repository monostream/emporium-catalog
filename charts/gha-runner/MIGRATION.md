# gha-runner 0.0.x -> 0.1.0 (Emporium 0.5)

## Removed and renamed inputs

- `GitHubURL`, `RunnerScaleSetName`, `MaxRunners`: same keys. `RunnerScaleSetName` is now
  install-only and must be a DNS label (lowercase letters, digits, `-`). `MaxRunners` defaults to 5
  (1..100); 0.0.x left it unset, which ARC treats as unlimited.
- `GitHubPAT`: same key, now `type: secret`, delivered by reference (`<app>-emporium-secrets`, key
  `github_token`, passed to ARC as `githubConfigSecret`). Re-enter the token when reinstalling.

## Database

None.

## Hostnames

None (no ingress: the listener and runners only talk outbound to GitHub).

## TLS secret

None.

## Secrets

- GitHub token: `<app>-emporium-secrets`, key `github_token` (0.0.x rendered it into the chart's
  `<release>-gha-rs-github-secret` from plain values).

## Data to keep before uninstalling a 0.4 install

Nothing: runners are ephemeral and the chart has no volumes. Uninstall the 0.4 release and
install 0.1.0 with the same `RunnerScaleSetName`; GitHub registers the scale set again.

## Behaviour changes

- The controller watches only its own namespace (`flags.watchSingleNamespace`), so it no longer
  picks up runner scale sets of other installs.
- The pre-upgrade hook applies the CRDs of the bundled controller version (0.15.0) instead of the
  pinned 0.9.2 CRDs, with `registry.k8s.io/kubectl:v1.35.9` (two containers, no shell).
- Resources: controller 50m/128Mi (limit 512Mi); runner container 250m/512Mi (limit 4Gi). The
  `dind` sidecar comes from the upstream chart without requests (runner pods are created by the
  controller, not rendered by Helm, so they are not components).
- The upstream gha-runner-scale-set chart calls `lookup` (lint `lookup-offline`): no manifest
  diff in preview.
