# 0.1.1

Published on 23 October 2026

- paperless-ngx from 3.3.3 to 3.3.4

# 0.1.0

- New chart: Paperless-ngx 3.3.3 (official image `ghcr.io/paperless-ngx/paperless-ngx`), requires Emporium v0.5.0.
- One pod runs the web server, consumer, Celery worker and scheduler; documents, media, index and the consume folder live on one volume (`data` storage integration).
- PostgreSQL 17 (`db`, CloudNativePG) and Redis (`redis`, Valkey), both connected by reference.
- Single sign-on through Emporium (`sso` OIDC integration, django-allauth `openid_connect`); accounts are created at the first sign-in; the `emporium-admin` role maps to Paperless-ngx superuser. A small `sitecustomize` patch lets allauth 65.16 accept Logto's ES384 signing keys.
- Optional SMTP integration for notifications and mail; optional Tika and Gotenberg endpoints (off by default).
- Local superuser created at the first start; the password is generated into the per-app Secret unless set at install.
- The REST API (`/api/`) skips the Emporium login so mobile apps and scripts work with their API token.
