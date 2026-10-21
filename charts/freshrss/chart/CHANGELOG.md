# 0.1.0

- New chart: FreshRSS 1.30.3 (official Debian image `freshrss/freshrss`; 1.30.4 had no image yet), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG); the small data volume holds the configuration.
- Single sign-on through Emporium: Apache mod_auth_openidc (ES384 ID tokens work) with HTTP authentication; the FreshRSS username is the Logto `preferred_username` and accounts are created at the first sign-in.
- The administrator (FreshRSS default user) is created at the first start from the "Administrator username" input; its generated password is delivered by reference and used by the "password" sign-in method.
- The Google Reader and Fever APIs under `/api/` skip the Emporium login so mobile apps work with the per-user API password.
- The administrator username input mirrors FreshRSS's username rules; the README documents the port-forward recovery for the password sign-in method, the identity-claim caveat and which `/api/` endpoints check their own credentials.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, SSO login as administrator and as a plain user, mobile API login, password mode, uninstall without leftovers.
