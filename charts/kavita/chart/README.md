# Kavita

Kavita is a fast, self-hosted digital library and reader for ebooks, comics and manga: point it at your folders and read everything in the browser, on every device, with your progress in sync.

## Features

- EPUB, PDF and CBZ/CBR/archive files; comics, manga and light novels with series, volumes and metadata from the files
- Browser reader with bookmarks, reading lists, collections, want-to-read and per-user progress
- OPDS catalogue and KOReader sync for reader apps (Panels, Chunky, Foliate, KOReader and more)
- Several users with their own libraries, age restrictions and reading history
- Single sign-on through Emporium: every Emporium user gets their own account at the first sign-in

## Perfect for

Households and small groups who keep their ebooks and comics on their own server and want one clean place to read, search and share them.

## Good to know

- **Single sign-on.** The "Sign in with Emporium" button creates the Kavita account at the first sign-in, named like the Emporium username. Kavita needs an e-mail address for every account, so an Emporium administrator must set an e-mail on the user first; users without one see "missing e-mail".
- **Roles.** Kavita can only map roles whose claim values are named like its own roles (for example `Admin`, `Login`), which Emporium's roles are not. New accounts therefore get the Login, Pleb and Download roles and access to the default "Books" library; the local administrator promotes users and grants libraries under Settings > Users.
- **Local administrator.** Created by the chart at the first start (name from the install form, default `kavita-admin`; the password is in the app's Secret). The first administrator is never created from the browser, so nobody can claim it. It is never synchronized from single sign-on. If you change its password in Kavita, the chart's setup only reports ready on later restarts and leaves Kavita's settings to you; the Secret then holds the initial password only.
- **Account linking.** A single sign-on login is linked automatically to an existing, not yet linked local account with the same e-mail address, without asking for that account's password, and Kavita falls back to other name claims when a username is taken. Do not mix local invitations (accounts with their own password) with Emporium users: create local accounts only for e-mail addresses no Emporium user has.
- **Secrets on the config volume.** Kavita stores the OIDC client secret in its SQLite database and copies `appsettings.json`, with the token signing key, into its daily backups under `config/backups`. Treat the config volume and its backups as secret; the chart cannot keep these values off it.
- **Library files.** The library volume is mounted at `/data`. The default "Books" library reads `/data/books`; add comics or manga as libraries on `/data/comics` or `/data/manga` in Kavita (Settings > Libraries) and copy files in, for example with `kubectl cp`. Kavita only reads files inside sub-folders of a library folder (for example `/data/books/<author>/<book>.epub`), not files placed directly in its root.
- **Reader apps.** OPDS (`/api/opds/<API key>/...`) and KOReader sync (`/api/koreader/<API key>/...`) skip the Emporium login; the secret is the per-user API key in the URL (Kavita > User settings > Account). Reader apps that use Kavita's full REST API with a bearer token (for example Mihon extensions) cannot reach it, because the rest of `/api` stays behind the Emporium login.
- **Database.** Kavita keeps everything in SQLite on the config volume (no PostgreSQL support), so there is exactly one replica and the config volume is part of every backup.
- **Statistics.** Anonymous usage statistics are switched off; the Kavita+ features need a paid upstream subscription.
