# Wallabag

Wallabag is a self-hosted read-it-later service: save a web page with one click, read it later in a clean, distraction-free view on any device, and keep it, even when the original disappears.

## Features

- Save articles from the browser, the bookmarklet, browser extensions or the mobile apps; the content is fetched, cleaned and stored
- Reader view with tags, tagging rules, highlights and notes, search, starred and archived lists
- Import from Pocket, Instapaper, Pinboard, Firefox, Chrome, Readability and Wallabag exports; export to EPUB, MOBI, PDF, CSV, JSON, TXT and XML
- RSS feeds of your unread, starred and archived articles
- Official Android and iOS apps, plus many third-party readers, through the REST API
- Several users, each with their own library

## Perfect for

Anyone who collects long reads and wants them in their own library: one place, searchable, annotated, independent of any service.

## Good to know

- **Sign-in.** Wallabag 2.6 has no single sign-on (OpenID Connect). Everything is behind the Emporium login, then you sign in to Wallabag with its own account. The administrator ("Users management") creates the accounts; self-registration is off.
- **Administrator.** Emporium creates the administrator before Wallabag serves its first request, with the username, email and password from the install form (password generated into the app's Secret if you leave it empty). The built-in `wallabag` / `wallabag` account that a stock Wallabag install creates does not exist.
- **Mobile apps and browser extensions.** Create an API client under "API clients management" (`/developer`) and enter its id and secret, your username and your password in the app. These calls use `/oauth/v2/token` and `/api/*`, which skip the Emporium login; Wallabag authenticates them with OAuth bearer tokens. `/api/info` and `/api/version` are public (version and whether registration is open); `POST /api/user` answers 403 while registration is off. The browser authorization flow `/oauth/v2/auth` and `/developer` stay behind the Emporium login.
- **Feeds.** `/feed/*` skips the Emporium login so feed readers can fetch your RSS feeds; each feed URL contains a secret token you can regenerate in your Wallabag settings.
- **Public share links** (`/share/...`) stay behind the Emporium login.
- **Not included.** Large imports run in the web request (the asynchronous Redis/RabbitMQ workers are not deployed), and Wallabag cannot send email (password resets and email two-factor codes), so an administrator resets forgotten passwords.
- **Storage.** The database lives in PostgreSQL; the volume holds the site-credentials encryption key and downloaded article images.
- **Image.** The upstream image runs nginx and php-fpm as root and drops to `nobody` for PHP, so the container keeps a small set of capabilities instead of a non-root user.
