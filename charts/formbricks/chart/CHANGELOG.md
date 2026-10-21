# 0.1.0

- New chart: Formbricks 6.1.0 (official image `ghcr.io/formbricks/formbricks`) with the Hub 0.14.0, Cube 1.7.50-1 and SpiceDB 1.52.0 services Formbricks 6 requires, requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG) with the `vector` and `pgcrypto` extensions; Redis through the `cache` integration; optional object storage and SMTP integrations.
- Admin interface behind the Emporium login; link surveys, the client SDK API, management APIs and static files skip it so respondents and API clients work. Formbricks single sign-on is Enterprise-licensed and not enabled.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, Emporium login in front of the admin interface, first account and organisation, public survey with responses through the client API, uninstall without leftovers. Formbricks single sign-on is Enterprise-licensed and was not exercised.
