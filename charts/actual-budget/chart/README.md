# Actual Budget

Actual is a local-first personal finance app: envelope budgeting, multiple accounts, rules, schedules and reports. This chart runs the Actual sync server, so the web app and every device share the same budgets, with optional end-to-end encryption of the budget file.

## Features

- Envelope budgeting with category groups, goals and rollover
- Accounts, split transactions, rules, schedules and reconciliation
- Reports and custom dashboards
- Import from CSV, OFX, QFX and other budgeting apps
- Works offline in the browser and syncs when connected
- Multiple users with their own budget files and file sharing

## Good to know

- **Who becomes the owner**: Actual makes the first identity that signs in the owner and administrator, and nothing can pre-set it. The install is therefore restricted to Emporium administrators by default. Sign in once as the intended owner, then change the access of the app to "authenticated" in Emporium so the other users can sign in. Later users are regular accounts (created at first sign-in, or by the owner first if you turn off account creation). Actual has no role mapping, so Emporium administrators are not made Actual administrators automatically. Your Actual username is your Emporium username.
- **Fails closed**: if the OpenID setup fails at start, the pod stays not ready instead of offering Actual's password bootstrap.
- **ID token algorithm**: Emporium's identity provider signs ID tokens with ES384, which Actual's OpenID client rejects in its default mode. The chart therefore uses `ACTUAL_OPENID_AUTH_METHOD=oauth2` (user read from the userinfo endpoint after the code exchange; the ID token is not validated).
- **No local password**: with single sign-on configured on fresh storage Actual keeps no password login. Reused storage from an older install may still hold a password, but the chart allows only the `openid` login method, so it cannot be used (this also keeps the session lifetime exact: Actual counts it in minutes for password sessions). Access is controlled by the Emporium login; the owner manages users under Server administration.
- **Open paths**: `/sync/*` and `/account/validate` skip the Emporium login so API clients can use their Actual session token. Bootstrap, login and admin endpoints stay behind it. Session tokens last 30 days (input); after an Emporium account is disabled its Actual token still works until it expires, so also disable the user in Server administration.
- **Upload limit**: the largest budget file (input, 50 MB) is also set as the ingress body size.
- **Data**: budgets are on the data volume. Through Emporium the keep/delete choice at uninstall applies (keep by default); with plain Helm the volume is kept.

Source and documentation: https://actualbudget.org/ (MIT licence).
