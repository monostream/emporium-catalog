# 0.2.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Ingress host, TLS secret and ingress class come from the `web` ingress integration (glass disabled, redirect paths `/oidc/callback` and `/admin/oidc/callback`; the second was missing its leading slash).
- OIDC client secret is read from the per-app Secret (`HEADSCALE_OIDC_CLIENT_SECRET`) instead of being written into the ConfigMap.
- Headplane cookie secret is a generated 32-character input (Headplane requires 32) instead of `randAlphaNum` + `lookup`.
- The root API key Secret no longer needs `lookup`; the post-install job uses `alpine/k8s` instead of the unpullable `bitnami/kubectl` and no longer prints the key.
- Dropped the unknown `custom` OIDC scope.
- Data volume is the `data` storage integration (1Gi default, grow-only).
- Default resources for headscale, Headplane and the job instead of none.

# 0.1.21

Published on 19 October 2026

- Removed nginx-only ingress annotations (proxy headers, HSTS, buffering, redirect, TLS protocols)

# 0.1.20

Published on 7 October 2026

- headscale from v0.23-debug to v0.29.4
- headplane from 0.3.5 to 0.7.1

