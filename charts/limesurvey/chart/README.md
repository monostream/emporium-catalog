# LimeSurvey

LimeSurvey is the open-source survey platform: build questionnaires with logic and quotas, send them to participants and analyse the answers on your own server.

LimeSurvey Community Edition (GPL-2.0-or-later) is the free self-hosted edition. LimeSurvey GmbH publishes no container image, so the chart uses the well-maintained community image `martialblog/limesurvey` (built from the official release tarball with a checksum), version 7.5.1 (the 6.x line is out of support upstream).

## Features

- Over 30 question types, conditional logic with expressions, randomisation, quotas and multi-language surveys
- Anonymous or token-based (invitation) surveys, email invitations and reminders, participant tables
- Themes and templates, file upload questions, partial saves and "resume later"
- Statistics, exports (CSV, Excel, SPSS, R) and an optional encryption of sensitive responses
- Roles and permissions per user and per survey; your data stays on your own PostgreSQL database

## Perfect for

Teams, schools and organisations that run customer, employee or research surveys and need full control over the data.

## Good to know

- **Two kinds of visitors.** The administration (`/index.php/admin`) sits behind the Emporium login: sign in to Emporium first, then to LimeSurvey. Respondents do not need an account: published surveys (`/index.php/<survey id>`, `/index.php/survey/...`), file uploads, the captcha image (`/index.php/verification/image`), registration, print-answers, opt-in/opt-out and public statistics pages, and static files (`/assets`, `/themes`, `/upload`, `/tmp/assets`, `/third_party`, `/scripts`, `/styles-public`) skip the Emporium login. Everything else, including the start page and the whole admin area, requires it.
- **Route parameters are refused.** LimeSurvey (Yii) lets a request pick any controller with an `r` query parameter or an `/r/<route>` path segment, even on a respondent URL. A PHP `auto_prepend_file` (`files/route-guard.php`, enabled in the chart's php.ini snippet) answers 403 to every web request whose parsed `$_GET`/`$_REQUEST` has an `r` key (after PHP's own name normalisation: `+r`, `r.`, `r%20`, `r%00`, `r[]` and so on), whose query string contains `%00`, or whose path has an `/r/` segment; an Apache rule (`files/block-route-param.conf`) additionally refuses `r` in the raw query and in the path. Normal LimeSurvey URLs use the path format and never need them; a custom plugin or integration that builds `index.php?r=...` URLs will not work.
- **No single sign-on.** LimeSurvey CE bundles no OpenID Connect login. The free community plugins (for example `FSW-AppTeam/LimeSurveyOIDCAuth`, based on `jumbojett/openid-connect-php`) cannot verify the ES384 ID tokens Logto signs, so Emporium identities are not mapped to LimeSurvey users. Sign in as `admin`; create further users under Configuration > Users.
- **Administrator.** The account `admin` is created at the first start with a generated password (the input `AdminPassword`, kept in the app's Secret; the post-install notes show the `kubectl` command). The password never appears in a process command line: the image's installer is run with a throwaway value derived (HMAC) from the real password, and an in-process step replaces it with the real one (from the Secret) before Apache starts. The environment values only matter for the first start: change the password and email in LimeSurvey afterwards, it is not reset on restart. There is no default password.
- **Data encryption.** The key and nonce for LimeSurvey's optional response encryption are generated at install and kept in the Secret (installOnly). Back them up with your database: encrypted data cannot be read without them.
- **TLS to the database.** The connection to PostgreSQL is encrypted and the server certificate is verified against the database's CA (`PGSSLMODE=verify-full`).
- **Uploads and plugins.** `/var/www/html/upload` is on a volume (survey files, user themes, plugins). PHP limits are 32 MB upload and 256 MB memory (`php.*` values). The image's `application/config` is generated at every start from the environment, so settings changed there are not kept; use LimeSurvey's own settings.
- **Public survey list and links.** Survey links use the `index.php/<id>` form; shortened or "pretty" URLs without `index.php` are not enabled.
- **Respondent exposure.** The respondent routes are reachable by anyone who knows the host name. Use survey access (tokens, expiry dates, activation) to restrict who may answer; LimeSurvey's own login lockout protects the admin login.
- The image runs as the unprivileged `www-data` user on port 8080 with all capabilities dropped; the root filesystem stays writable because LimeSurvey writes configuration and caches into its application directory.
- **Updates are manual.** The image tags (`7.5.1-261021-apache`) carry a build date and exist for several variants and major versions, which the catalog's image updater cannot express (Apache variant, 7.x only), so the chart has no `deps.json`. Bump `image.tag` and `appVersion` by hand within the `7.x-apache` family.
