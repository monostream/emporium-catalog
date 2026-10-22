# 0.1.0

- New chart: LimeSurvey Community Edition 7.5.1 (community image `martialblog/limesurvey`, GPL-2.0-or-later), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG), connection with `PGSSLMODE=verify-full` and the integration CA; uploads, themes and plugins on a storage volume.
- Behind the Emporium login (`access: authenticated`); published surveys, their assets and the respondent routes skip it, so respondents need no account. LimeSurvey keeps its own accounts (no free OpenID Connect plugin verifies Logto's ES384 tokens).
- Administrator password, data encryption key and nonce are generated at install (installOnly, by Secret reference); no default credentials.
- Tested on Emporium 0.5.0-rc.12 (2026-10-22): install, Emporium login then LimeSurvey login with the generated password, demo survey imported and activated, respondent opened it without any login, admin area without an Emporium session redirects to the login, TLS verify-full to PostgreSQL (TLSv1.3), uninstall without leftovers.
