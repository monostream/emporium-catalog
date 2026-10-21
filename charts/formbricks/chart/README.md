# Formbricks

Formbricks is an open source survey and experience management platform: ask customers and users questions with link surveys, on your website or inside your product, and collect the answers on your own server.

## Features

- Link surveys you share by URL or embed in emails, website and in-app surveys through the JavaScript SDK
- Many question types with logic, recall, multiple languages, custom styling and a custom survey URL
- Responses with filters, summaries, charts and dashboards, CSV export, webhooks and a REST API
- Contacts and segments to target the right people
- PostgreSQL storage, with the pgvector extension for feedback analysis

## Perfect for

Product, support and research teams who want customer feedback and survey data to stay on their own infrastructure.

## Good to know

- **Sign-in.** Formbricks' single sign-on (OpenID Connect, SAML, Google, GitHub, Microsoft) is part of the Formbricks Enterprise Edition (`/apps/web/modules/ee`, separate licence) and needs a licence key. This chart ships without it: the admin interface is protected by the Emporium login (only signed-in Emporium users reach it), and Formbricks has its own email and password accounts behind that. Set `ENTERPRISE_LICENSE_KEY` and the `OIDC_*` variables through `extraEnv` if you hold a licence.
- **First account.** The first person who opens the instance creates the first account at `/auth/signup`; that account owns the organisation. Sign-up is closed afterwards: further people join by invitation (Organisation settings > Members) or by an invite link. Mail is only needed if you want email verification, password reset or invitation emails; add the SMTP integration for that.
- **Public paths.** Respondents do not have an Emporium account, so link surveys (`/s/...`, `/c/...`, `/p/...`), the survey client API and SDK files (`/api/v1/client/...`, `/api/v2/client/...`, `/js/...`), the management APIs (they need a Formbricks API key), uploaded public files (`/storage/...`) and the static files those pages load skip the Emporium login. Everything else, including the dashboard and sign-in pages, requires it.
- **What runs.** Formbricks 6 consists of the web application, the Formbricks Hub (API and background worker for feedback records), Cube (analytics queries) and SpiceDB (authorisation). They share one PostgreSQL database from Emporium (pgvector enabled), Redis holds queues and sessions. SpiceDB stores its relationships in the same database.
- **File uploads.** Questions that upload files and image backgrounds need S3 compatible storage: add the object storage integration. Without it those features are unavailable.
- **Licence.** The Formbricks core is AGPL-3.0; the `ee` directory is under the Formbricks Enterprise licence and its features stay locked without a key. The chart does not enable them.
- **Updates.** Each Formbricks release is paired with a Hub, Cube and SpiceDB version (the chart pins the tested set). Database migrations of all four run when the pod starts.
