# 0.1.0

- New chart: Outline 1.11.0 (official image `outlinewiki/outline`, Business Source License 1.1), requires Emporium v0.5.0.
- PostgreSQL 17 (`db`, CloudNativePG), Redis (`cache`, persistent) and a persistent volume for attachments (`data`, `FILE_STORAGE=local`); optional SMTP for invitations and notifications.
- Single sign-on through Emporium (`sso` OIDC integration, issuer discovery, "Continue with Emporium"); an email address is required. The first user to sign in becomes the workspace administrator.
- `SECRET_KEY` and `UTILS_SECRET` are generated once into the per-app Secret.
- The REST API and shared documents skip the Emporium login.
- Public share pages: `/static/*`, `/fonts/*`, `/images/*` and `/locales/*` skip the Emporium login so shared documents can load.
- SMTP: implicit TLS only on port 465, STARTTLS otherwise; `db`, `cache` and `data` are explicitly required.
- The Ingress sets `proxy-body-size` to the upload limit plus 5 MB so attachments are not rejected with 413.
