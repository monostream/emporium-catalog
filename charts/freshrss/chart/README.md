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

- **Administrator.** At install you enter the Emporium username of the first administrator. That user is the FreshRSS administrator at their first sign-in; every other Emporium user gets a regular account at the first sign-in, named like the Emporium username. FreshRSS has a single "default user"; further administrators are made under Administration > Manage users. Emporium roles are not mapped to FreshRSS roles. Usernames follow FreshRSS's rules: letters, digits and `_ . @ -`, 1 to 39 characters, not starting with `.`, `-` or `@`.
- **Recovery.** If you entered a name that nobody can sign in as, run `kubectl exec -n <namespace> deploy/<app> -- su www-data -s /bin/sh -c "php cli/reconfigure.php --default-user <name>"`. To sign in without single sign-on, set "Sign-in method" to "password": FreshRSS then shows its own login form and only the administrator can sign in, with the generated password in the app's Secret (`AdminPassword`). This only replaces the FreshRSS single sign-on: the Emporium login in front of the app still applies. If Emporium's own login is down, reach the form through the pod: `kubectl -n <namespace> port-forward deploy/<app> 8080:8080` and open http://localhost:8080/i/.
- **Identity.** Users are matched by the `preferred_username` claim, which Emporium sets from the Logto username. Keep Logto's account profile editing (the Account API that lets users change their profile username) disabled for Emporium users: in some Logto versions that profile value overrides the claim, so a user could present the administrator's name and be signed in as the administrator. The opaque `sub` claim is not used because FreshRSS identifies the administrator by name.
- **Mobile apps.** In FreshRSS open Settings > Profile, set an "API password", then use `https://<host>/api/greader.php` (Google Reader API, e.g. FeedMe, Reeder, NetNewsWire, Read You) or `https://<host>/api/fever.php`. Everything under `/api/` skips the Emporium login. The Google Reader and Fever endpoints require that API password; WebSub callbacks (`/api/pshb.php`) are verified by FreshRSS, shared queries (`/api/query.php?t=<token>`) are readable by anyone with the token, and extension endpoints (`/api/misc.php`) are public: FreshRSS does no credential check there, so authentication is up to each extension. Only enable extensions with API endpoints you trust. The web interface (`/i/`) always needs the Emporium login plus the FreshRSS single sign-on, which is silent when you are already signed in.
- **Shared feeds.** The "shareable" feed links of the web interface (`/i/?a=rss&...`) live in the protected `/i/` and need the Emporium login; share a user query through `/api/query.php` instead if it must be public.
- **Feed refresh.** Feeds are refreshed by a cron job inside the app every 15, 30 or 60 minutes (setting "Refresh interval"). Articles live in PostgreSQL; the small data volume holds the configuration and user settings.
- **Extensions** installed from the web interface are kept only until the pod restarts.
