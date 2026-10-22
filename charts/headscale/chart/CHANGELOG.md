# 0.2.3

Published on 22 October 2026

- headscale from v0.29.4 to v0.29.5
- headplane from 0.7.1 to 0.8.1

# 0.2.2

Published on 21 October 2026

- Category: Security (was Utilities).

# 0.2.1

Published on 21 October 2026

- Headplane 0.7.1 is configured in its current format: a rendered `/etc/headplane/config.yaml` (server `base_url`, `cookie_secure` from the https URL, headscale URL and config path, OIDC issuer, client id, `use_pkce`) plus `HEADPLANE_*` overrides for the three secrets (cookie secret, OIDC client secret, headscale API key), all by `secretKeyRef`. The pre-0.5 flat variables (`OIDC_*`, `HEADSCALE_URL`, `COOKIE_*`, `ROOT_API_KEY`, `DEBUG`) are gone. Headplane state is stored on the data volume (`/var/lib/headplane`, subPath `headplane`).
- The Headplane admin UI can sign in through OIDC again. The API key login stays enabled as the break-glass path (`web.disableApiKeyLogin`, default `false`).
- headscale 0.29 refused to start with the old configuration because `randomize_client_port` was removed (fatal). `ephemeral_node_inactivity_timeout` was renamed to `node.ephemeral.inactivity_timeout` (only a deprecation warning). Both are fixed. SQL debug logging (`database.debug`) is off.
- The post-install job could not create the API key (`kubectl exec` needs `create` on `pods/exec` with current kubectl, and a failure was silent): RBAC fixed (secret and deployment writes limited by `resourceNames`; exec stays namespace-wide because pod names are generated), the job retries and fails loudly, and the hook is deleted after it succeeds. Without the key Headplane starts with OIDC disabled (it does not crash-loop); the job stamps the key's fingerprint on the pod template so Headplane restarts once and every retry converges.
- Pods roll when the headscale or Headplane ConfigMap changes (`checksum/*` annotations), so `oidc.allowedDomains`, `oidc.allowedUsers` and `web.disableApiKeyLogin` take effect on upgrade.
- New opt-in `oidc.allowedDomains` / `oidc.allowedUsers` restrict who may register nodes through headscale OIDC (default: unrestricted).
- The post-install job waits for the headscale container instead of the whole pod (Headplane needs the API key the job creates).

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

