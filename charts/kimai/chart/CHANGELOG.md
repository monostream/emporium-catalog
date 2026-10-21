# 0.1.0

- New chart: Kimai 2.70.1 (official image `kimai/kimai2`, Apache variant, AGPL-3.0), requires Emporium v0.5.0.
- MariaDB 11.4 (official image) as a chart-local StatefulSet, because Kimai supports only MySQL/MariaDB and Emporium has no provider for it; credentials generated into the per-app Secret and delivered by reference, volume managed through a `storage` integration.
- No single sign-on: Kimai's OpenID Connect is not available, its SAML login is built in but needs a SAML identity provider that Emporium does not offer. The app is served behind the Emporium login.
- Super administrator `admin` created at the first start; the password is generated into the per-app Secret unless set at install.
- The REST API (`/api/*`, API tokens) skips the Emporium login so the mobile apps and scripts work.
- Tested on Emporium 0.5.0-rc.12 (2026-10-21): install, Emporium login in front of the Kimai login, local administrator login, REST API token, uninstall without leftovers.
