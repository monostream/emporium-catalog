# Changelog

## 0.1.0

- First release of the Hoppscotch Community Edition chart (Hoppscotch 2026.9.0, all-in-one image in single-port subpath mode).
- PostgreSQL through the Emporium `postgres` integration; database migrations run at every start.
- E-mail sign-in is set up at the first start from the Emporium `smtp` integration.
- The administrator is an install input (e-mail); the account is created at the first start, which also locks Hoppscotch's setup wizard.
- The pod is not Ready (no traffic) until the setup and the administrator account are done.
- Behind the Emporium login; the CLI access-token endpoints skip it.
