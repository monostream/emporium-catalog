# 0.1.0
- First release: Actual Budget sync server 26.10.0 (official `actualbudget/actual-server` image).
- Budgets and the account database (SQLite) live on the `data` storage integration (2Gi default, grow-only), so the uninstall keep/delete choice applies; data is kept by default.
- Single sign-on through Emporium (OpenID Connect, `sso` integration). Actual's OpenID client runs in `oauth2` mode because Emporium's identity provider signs ID tokens with ES384, which Actual's default OpenID mode rejects. The first user to sign in is the owner and administrator; Actual has no role mapping.
- Callback `/openid/callback` is registered as redirect path; `/sync/*` and `/account/*` skip the Emporium login for API clients.
