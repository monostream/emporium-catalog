# PhotoPrism

[PhotoPrism](https://www.photoprism.app/) is a self-hosted photo library. It indexes photos and videos from your own storage, labels them with built-in image classification, recognises faces, shows them on a map and in a timeline, and shares albums by link, without handing your pictures to a cloud service.

## What you get

- Library with search, albums, labels (automatic classification), people, places and calendar, RAW and video support.
- Two volumes: **originals** (your photos and videos, default 50 Gi) and **storage** (SQLite database, thumbnails, cache and sidecar files, default 10 Gi). Both can grow, not shrink.
- Single sign-on with your Emporium account; Emporium administrators become PhotoPrism administrators.
- A local administrator for emergencies, with a generated password.

## Good to know

- **Community Edition.** The image is the official `photoprism/photoprism` build, AGPL-3.0, free to self-host. PhotoPrism sells Plus (membership) and Pro/Enterprise editions; the Community Edition has everything described here but lacks the Pro features (user management UI and API, roles beyond admin and guest, session monitoring, audit log, rate limiter).
- **Database: SQLite, one instance.** PhotoPrism has no supported PostgreSQL mode in this release (MariaDB is the upstream recommendation, PostgreSQL is a development preview). The chart uses SQLite on the storage volume, so there is exactly one replica and indexing gets slower for libraries of several hundred thousand files. A MariaDB option is not part of this chart.
- **Single sign-on.** Use "Continue with Emporium" on the login page (or switch on "Sign in automatically"). Accounts are created at the first sign-in and named like the Emporium username. Members of the Emporium role `emporium-admin` become PhotoPrism administrators at every sign-in (the `roles` claim is mapped with `PHOTOPRISM_OIDC_GROUP_ROLE`; the role can be changed in Emporium, the PhotoPrism account follows at the next sign-in). The ID tokens Logto signs with ES384 are accepted.
- **Roles of other users.** Community Edition knows only `admin` and `guest`. New single sign-on users are **guests** by default: they see only albums that were shared with them (and can react to them), not the library. Set "Role of new single sign-on users" to `admin` if every Emporium user may manage the whole library. There is no middle role in Community Edition.
- **Local administrator.** The account `photoprism-admin` (name configurable at install) is created from the generated password at the first start; the password is in the app's Secret (command in the install notes). The password input only takes effect for an empty database. With automatic sign-in on, the local administrator uses `/library/login?nosso`.
- **Public mode is off.** `PHOTOPRISM_AUTH_MODE=password`: every request to the library needs a login.
- **Paths that skip the Emporium login.** `/s/*` (share links), `/library/*` and `/static/*` (the web app: a share link creates an anonymous link session and then loads the web app), `/api/v1/*` (the web app's API, mobile apps; authenticated by PhotoPrism with session tokens, app passwords or the share link token) and `/originals/*`, `/import/*` (WebDAV with an app password or the account password). Only `/` stays behind the Emporium login, so PhotoPrism's own login protects the library; sign-in attempts are not rate limited in Community Edition. Single sign-on users may use WebDAV only when "WebDAV for single sign-on users" is on and an administrator enables it for the account.
- **Share links** (Albums > Share) work for anonymous visitors; set a password or an expiry on the link if the album is sensitive.
- **Indexing is CPU and memory heavy.** The image classifier and face detection run on the CPU. The default profile requests 500m CPU and 1 Gi and limits memory to 3 Gi; "Indexing workers" defaults to 2 (a smoke test with 14 photos peaked at about 550 MiB). Raise the workers only with a larger profile. No GPU.
- **Telemetry.** PhotoPrism's usage info is off by default and the chart does not enable it.

## Upstream

AGPL-3.0, <https://github.com/photoprism/photoprism>. The logo is the official PhotoPrism icon (PhotoPrism(R) is a registered trademark of PhotoPrism UG). The gallery photos are public-domain US National Park Service pictures (Great Smoky Mountains and Rocky Mountain National Parks) from Wikimedia Commons.
