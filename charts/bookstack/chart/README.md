# BookStack

[BookStack](https://www.bookstackapp.com/) is a simple, self-hosted wiki. Pages live in chapters, chapters in books, books on shelves, with a WYSIWYG and a Markdown editor, drawings, attachments, full-text search, page revisions and fine-grained permissions.

## What you get

- A team knowledge base with books, chapters, pages, shelves, tags and search.
- MariaDB on its own volume, and a volume for uploaded images and attachments.
- A REST API with API tokens, and webhooks.
- A local administrator with a generated password.

## Good to know

- **No single sign-on.** BookStack's OpenID Connect login only accepts ID tokens signed with RS256 ([BookStack #5390](https://github.com/BookStackApp/BookStack/issues/5390), [#5915](https://github.com/BookStackApp/BookStack/issues/5915)); the Emporium login provider signs with ES384, so BookStack cannot use it. The chart therefore has no `oidc` integration. The app is behind the Emporium login (everyone must be signed in to Emporium), and inside it people sign in with a BookStack account created by the administrator under Settings > Users (or by open registration, if you enable it in Settings).
- **Local administrator.** BookStack seeds `admin@admin.com` with the public password `password`. An init container replaces that account with the configured email and password before the web server starts, so the default login is never reachable. Read the password with the command in the install notes (Secret `<app>-emporium-secrets`, key `AdminPassword`). If the default account was already changed, it is left alone.
- **API.** `/api/*` skips the Emporium login and is authenticated by BookStack with API tokens (profile > API Tokens, `Authorization: Token <id>:<secret>`); the interactive docs at `/api/docs` are under the same skipped path, so they are not behind the Emporium login either; BookStack itself requires a signed-in BookStack user for them.
- **Image.** BookStack publishes no container image; the chart uses the community image `solidnerd/bookstack` (MIT, built from the BookStack release tag), linked from the BookStack documentation.
- **Email** (invites, password resets) is not configured; set the `MAIL_*` variables through `extraEnv` if you need it.

## Upstream

MIT, <https://github.com/BookStackApp/BookStack>. The icon is the official BookStack icon.
