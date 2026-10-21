# Kimai

Kimai is a professional time-tracking application: start a timer or enter hours for your projects, then turn them into invoices and reports. Teams get customers, projects and activities, rates, budgets, approvals and an export for every accountant.

## Features

- One-click timer, calendar and manual entries, on desktop, mobile and through the API
- Customers, projects and activities with hourly rates, budgets and teams with permissions
- Invoices from your hours, with templates, and exports to CSV, Excel and PDF
- Reports and dashboards for weeks, months and projects
- Two-factor login, per-user time zones and languages

## Perfect for

Freelancers, agencies and small teams who bill by the hour and want their time data on their own server.

## Good to know

- Kimai's free edition has no OpenID Connect login (it has SAML and LDAP, which need an identity provider Emporium does not provide). The app sits behind the Emporium login, and inside it users sign in with Kimai accounts.
- The local super administrator is `admin` (email from the install form, password in the app's Secret). Create the other users under System > Users.
- Mobile apps and scripts call the REST API (`/api/...`) with Kimai API tokens (profile > API); that path is reachable without the Emporium login.
- Kimai needs MySQL or MariaDB and Emporium has no provider for them yet, so the chart runs a small MariaDB 11.4 (official image) next to the app, on its own volume, with generated passwords. It is part of the install and is removed with it.
- Emails (password resets, notifications) are off. To enable them add `MAILER_URL` (an SMTP URL, see the Kimai email documentation) under Advanced as an extra environment variable. Password-reset requests also need `TRUSTED_HOSTS` set to a regular expression for this app's host (for example `^kimai\.example\.com$`); without it Kimai answers 503. Do not set it blindly: the health probes call the pod by IP, so include `^[0-9.]+(:[0-9]+)?$` as well, for example `^(kimai\.example\.com|[0-9.]+(:[0-9]+)?)$`.
