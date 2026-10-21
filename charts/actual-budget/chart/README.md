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

- **Single sign-on**: the login page offers "Sign in with OpenID". The first account that signs in becomes the owner and administrator; later users are regular accounts (created at first sign-in, or by the owner first if you turn off account creation). Actual has no role mapping, so Emporium administrators are not made Actual administrators automatically. Your Actual username is your Emporium username.
- **ID token algorithm**: Emporium's identity provider signs ID tokens with ES384, which Actual's OpenID client rejects in its default mode. The chart therefore uses `ACTUAL_OPENID_AUTH_METHOD=oauth2` (user read from the userinfo endpoint after the code exchange).
- **No local password**: with single sign-on configured Actual keeps no password login. Access is controlled by the Emporium login; the owner can manage users under Server administration.
- **Open paths**: `/sync/*` and `/account/*` skip the Emporium login so API clients can use their Actual session token. The web app itself is behind the Emporium login.
- **Data**: budgets are on the data volume and kept on uninstall unless you choose to delete them.

Source and documentation: https://actualbudget.org/ (MIT licence).
