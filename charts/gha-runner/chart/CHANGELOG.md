# 0.1.1

Published on 27 October 2026

- gha-runner-scale-set-controller from 0.15.0 to 0.15.1
- gha-runner-scale-set from 0.15.0 to 0.15.1

# 0.1.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- The GitHub personal access token is read from the app's Secret (key `github_token`) instead of plain values.
- Maximum runners defaults to 5 (was unset, which means unlimited); the runner container requests 250m CPU and 512Mi memory (limit 4Gi), the controller 50m and 128Mi.
- The controller only watches its own namespace, so several installs no longer reconcile each other's runner scale sets.
- Fixed: the pre-upgrade hook applied the CRDs of ARC 0.9.2 on every upgrade (older than the bundled 0.15.0). It now applies the CRDs of the bundled version, with the `registry.k8s.io/kubectl` image instead of a Bitnami kubectl.
- The runner scale set name can no longer change after the install.

# 0.0.23

Published on 7 October 2026

- gha-runner-scale-set from 0.13.1 to 0.15.0
- gha-runner-scale-set-controller from 0.13.1 to 0.15.0

# 0.0.22

Published on 23 December 2025

- gha-runner-scale-set from 0.13.0 to 0.13.1
- gha-runner-scale-set-controller from 0.13.0 to 0.13.1

# 0.0.21

Published on 20 October 2025

- gha-runner-scale-set from 0.12.1 to 0.13.0
- gha-runner-scale-set-controller from 0.12.1 to 0.13.0

# 0.0.20

Published on 27 June 2025

- gha-runner-scale-set from 0.12.0 to 0.12.1
- gha-runner-scale-set-controller from 0.12.0 to 0.12.1

# 0.0.19

Published on 13 June 2025

- gha-runner-scale-set from 0.11.0 to 0.12.0
- gha-runner-scale-set-controller from 0.11.0 to 0.12.0

# 0.0.18

Published on 25 March 2025

- gha-runner-scale-set from 0.10.1 to 0.11.0
- gha-runner-scale-set-controller from 0.10.1 to 0.11.0

# 0.0.17

Published on 18 December 2024

- gha-runner-scale-set-controller from 0.10.0 to 0.10.1
- gha-runner-scale-set from 0.10.0 to 0.10.1

# 0.0.16

Published on 16 December 2024

- gha-runner-scale-set-controller from 0.9.3 to 0.10.0
- gha-runner-scale-set from 0.9.3 to 0.10.0

# 0.0.15

Published on 25 June 2024

- gha-runner-scale-set from 0.9.2 to 0.9.3
- gha-runner-scale-set-controller from 0.9.2 to 0.9.3

# Updates Monday, 20-May-2024 17:02:40 UTC
- gha-runner-scale-set from 0.9.1 to 0.9.2
- gha-runner-scale-set-controller from 0.9.1 to 0.9.2

# Updates Wednesday, 17-Apr-2024 17:03:24 UTC
- gha-runner-scale-set-controller from 0.9.0 to 0.9.1
- gha-runner-scale-set from 0.9.0 to 0.9.1

