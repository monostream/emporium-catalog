# FreshRSS

FreshRSS is a fast, lightweight and customizable feed aggregator: subscribe to websites, blogs and podcasts, read everything in one place, and keep your reading state in sync with your phone.

## Features

- RSS, Atom and JSON feeds, plus web scraping (XPath, JSON, HTML) for sites without a feed; OPML import and export
- Multi-user: every Emporium user gets their own feeds, categories and reading state
- Filters, labels, favourites, search, keyboard shortcuts, themes and a large extension ecosystem
- Works with mobile and desktop apps through the Google Reader API and the Fever API
- Single sign-on through Emporium: no extra password to remember

## Perfect for

People and teams who want one private, self-hosted reader that is quick to set up, supports many users and works with their favourite news apps.

## Good to know

- **Administrator.** At install you enter the Emporium username of the first administrator. That user is the FreshRSS administrator at their first sign-in; every other Emporium user gets a regular account at the first sign-in, named like the Emporium username. FreshRSS has a single "default user"; further administrators are made under Administration > Manage users. Emporium roles are not mapped to FreshRSS roles. Usernames are limited to letters, digits, `_ . @ -` and 38 characters.
- **Recovery.** If you entered a name that nobody can sign in as, run `kubectl exec -n <namespace> deploy/<app> -- su www-data -s /bin/sh -c "php cli/reconfigure.php --default-user <name>"`. To sign in without single sign-on, set "Sign-in method" to "password": FreshRSS then shows its own login form and only the administrator can sign in, with the generated password in the app's Secret (`AdminPassword`).
- **Mobile apps.** In FreshRSS open Settings > Profile, set an "API password", then use `https://<host>/api/greader.php` (Google Reader API, e.g. FeedMe, Reeder, NetNewsWire, Read You) or `https://<host>/api/fever.php`. Everything under `/api/` skips the Emporium login and is protected by that API password. The web interface (`/i/`) always needs the Emporium login plus the FreshRSS single sign-on, which is silent when you are already signed in.
- **Shared feeds.** Public "shareable" feed links of FreshRSS (`/i/?a=rss&...`) live in the protected web interface and need the Emporium login.
- **Feed refresh.** Feeds are refreshed by a cron job inside the app every 15, 30 or 60 minutes (setting "Refresh interval"). Articles live in PostgreSQL; the small data volume holds the configuration and user settings.
- **Extensions** installed from the web interface are kept only until the pod restarts.
