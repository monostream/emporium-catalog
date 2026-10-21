# Paperless-ngx

Paperless-ngx turns your paper mountain into a searchable digital archive. Scan or upload a document and it is read with OCR, indexed, tagged and filed, ready to be found in seconds.

## Features

- OCR of scans and PDFs in many languages, with full-text search and a PDF/A archive copy of every document
- Automatic tags, correspondents and document types learned from how you file
- Consume folder, e-mail import, web upload and mobile apps
- Storage paths, custom fields, workflows, sharing and per-user permissions
- Single sign-on through Emporium: every Emporium user gets an account at the first sign-in, Emporium administrators become Paperless-ngx superusers

## Perfect for

Households, freelancers and small offices who want every invoice, contract and letter in one private, searchable place.

## Good to know

- Sign in with the "Emporium" button. The Paperless-ngx username is the Emporium (Logto) username; no e-mail is needed. An Emporium user whose username matches an existing local account (for example `admin`) cannot sign in by SSO.
- The local superuser (created at install, password in the app's Secret) works without SSO. Users with the Emporium role `emporium-admin` become superusers at every SSO sign-in; everyone else is a regular user without permissions until an administrator grants them (Settings > Users and groups).
- The REST API (`/api/`) skips the Emporium login so mobile apps and scripts can use their API token.
- Office documents and e-mails (`.docx`, `.xlsx`, `.eml`, ...) need Apache Tika and Gotenberg. They are off by default; run both (for example as Emporium apps or in the same cluster) and enter their URLs in the install form to turn them on.
- OCR uses about 1 GB of memory per document in parallel. The Small profile processes one document at a time; raise the memory and the worker count together in the component settings.
- The image includes the OCR languages eng, deu, fra, ita and spa.
- django-allauth 65.16 (shipped with Paperless-ngx 3.3) cannot verify the ES384 ID tokens of Logto. The chart mounts a four-line `sitecustomize.py` that adds EC key support; it can be dropped once Paperless-ngx ships allauth 65.17 or newer.
