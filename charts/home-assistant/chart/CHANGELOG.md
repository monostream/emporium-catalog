# 0.1.0

- New chart: Home Assistant Core 2026.10.2 (Apache-2.0) from the official image `ghcr.io/home-assistant/home-assistant`, requires Emporium v0.5.0.
- Configuration, `.storage` and the default SQLite history on one storage volume (`/config`); a single replica; no `hostNetwork`.
- Reverse-proxy settings (`use_x_forwarded_for`, `trusted_proxies`) are written into `.storage/http` (the store that replaced the `http:` YAML key in Home Assistant 2026.10) before every start; the recorder block goes to `/config/emporium.yaml`, included from `configuration.yaml` as a package.
- The owner account is created through the onboarding API by a sidecar as soon as Home Assistant answers, with a generated password delivered by Secret reference.
- Optional recorder database on the Emporium PostgreSQL (CloudNativePG) integration.
- Behind the Emporium login (`access: authenticated`); `/api/*` and `/auth/*` skip it because Home Assistant authenticates them itself.

# 0.1.0 review fixes (same version, not yet released)

- Readiness gate: the pod is Ready only after the onboard sidecar has created the owner and logged in with the generated password; owner bootstrap done by someone else leaves the pod unready.
- Recorder over PostgreSQL uses `sslmode=verify-full` with the integration CA; the URL is built at runtime from Secret references.
- `.storage/http` writer deep-copies, changes only `use_x_forwarded_for` and `trusted_proxies` (stable and pending), keeps pending state; new stores get `login_attempts_threshold: 10`.
- `AdminPassword` is install-only; the onboard sidecar is a `parent` component.
