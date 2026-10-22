# 0.1.0

- New chart: LimeSurvey Community Edition 7.5.1 (community image `martialblog/limesurvey`, GPL-2.0-or-later), requires Emporium v0.5.0.
- PostgreSQL 17 through the `db` postgres integration (CloudNativePG), connection with `PGSSLMODE=verify-full` and the integration CA; uploads, themes and plugins on a storage volume.
- Behind the Emporium login (`access: authenticated`); published surveys, their assets and the respondent routes skip it, so respondents need no account. LimeSurvey keeps its own accounts (no free OpenID Connect plugin verifies Logto's ES384 tokens).
- Administrator password, data encryption key and nonce are generated at install (installOnly, by Secret reference); no default credentials.
- Respondent routes: captcha image (`/index.php/verification/image`), registration, print answers, opt-in/opt-out and public statistics skip the Emporium login. Requests with an `r` query parameter (checked after PHP normalisation in an auto-prepended PHP guard, plus an Apache rule) or `/r/` path segment (Yii route override) get 403, so skipped prefixes cannot reach admin, API or plugin routes.
- The administrator password is set in-process after a throwaway-password install, so it never appears in process arguments.
- No `deps.json`: automatic image updates are off, bump the tag manually.
- Tested on Emporium 0.5.0-rc.12 (2026-10-22): install, Emporium login then LimeSurvey login with the generated password, demo survey imported and activated (admin UI works with the route-parameter block), respondent opened it without any login, route-override URLs return 403, admin area without an Emporium session redirects to the login, TLS verify-full to PostgreSQL, uninstall without leftovers.
