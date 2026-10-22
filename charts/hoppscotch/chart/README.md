# Hoppscotch

Hoppscotch is a fast, open source API development workspace in the browser: build and send REST, GraphQL, WebSocket, Server-Sent Events, Socket.IO and MQTT requests, organise them in collections, switch between environments, write pre-request scripts and tests, and generate API documentation. Teams share collections and environments in workspaces on your own server.

## Perfect for

- Teams that want a self-hosted alternative to Postman or Insomnia, with their request data on their own infrastructure.
- Sharing API collections, environments and documentation inside a company.
- Quick API testing from any browser, without installing anything.

## What this chart runs

- The official all-in-one image `hoppscotch/hoppscotch` (app, admin dashboard and backend behind one web server on one port).
- PostgreSQL provided by Emporium.
- Single sign-on: not available. See "Good to know".

## Good to know

- **No OpenID Connect in the Community Edition.** Single sign-on is an Enterprise feature of Hoppscotch; the community backend only knows e-mail links, Google, GitHub and Microsoft sign-in. Hoppscotch is therefore published behind the Emporium login: nobody reaches it without an Emporium session, and people then sign in to Hoppscotch with their e-mail address.
- **The administrator is the e-mail address you enter at install.** The chart creates that account at the first start, right after the e-mail sign-in setup, and Hoppscotch then refuses to re-run its setup wizard. Nobody else can claim the administrator role. Sign in with that address and open `/admin`; more administrators are made there (Users). The first visit asks whether to share anonymous usage data and to receive news; both are your choice.
- **E-mail sign-in needs the Emporium SMTP integration.** The chart sets it up at the first start (Hoppscotch keeps these settings in its database, not in environment variables). Later changes, and the optional Google, GitHub and Microsoft sign-in, are made under `/admin` > Settings; the backend restarts itself after a change.
- **Paths that skip the Emporium login:** only the endpoints the Hoppscotch CLI uses with an access token (`/backend/v1/access-tokens/collection/*` and `.../environment/*`). The backend checks the token itself.
- Shared request links (`/r/...`) and published documentation can only be opened by people who have an Emporium session.
- The data encryption key (set at install) protects the stored SMTP password and OAuth secrets; keep the Secret when you restore from a backup.
- The desktop app and the mock server need extra hostnames and are not set up by this chart.
