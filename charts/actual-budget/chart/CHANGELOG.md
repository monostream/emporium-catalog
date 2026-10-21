# 0.1.0
- First release: Actual Budget sync server 26.10.0 (official `actualbudget/actual-server` image).
- Budgets and the account database (SQLite) live on the `data` storage integration (2Gi default, grow-only), so the uninstall keep/delete choice applies; data is kept by default.
- Single sign-on through Emporium (OpenID Connect, `sso` integration). Actual's OpenID client runs in `oauth2` mode because Emporium's identity provider signs ID tokens with ES384, which Actual's default OpenID mode rejects. The first user to sign in is the owner and administrator; Actual has no role mapping.
- Callback `/openid/callback` is registered as redirect path; only `/sync/*` and `/account/validate` skip the Emporium login (bootstrap, login and admin endpoints stay behind it).
- Access defaults to administrators because the first identity that signs in becomes the Actual owner; switch to authenticated afterwards. The readiness probe fails closed when the OpenID setup did not complete.
- Session lifetime input (30 days), ingress `proxy-body-size` follows the upload limit, standalone PVC is kept on Helm uninstall.
