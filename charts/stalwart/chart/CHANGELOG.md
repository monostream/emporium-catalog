# Changelog

## 0.1.0

- First release of the Stalwart Mail Server chart (Stalwart v0.16.27, community edition, AGPL-3.0).
- First-start setup through the bootstrap API (host name, first domain, RocksDB on the Emporium volume, logs on stdout); administrator from a generated Secret.
- Web administration behind the Emporium login; JMAP, DAV, discovery and OAuth endpoints skip it.
- Optional Service for the mail ports (`mail.service.*`, ClusterIP by default).
- No `oidc` integration: Stalwart's OIDC support is a token-validating directory without a web login flow.
- JMAP (`/jmap/*`), DAV (`/dav/*`) and `/api/discover` are not skipped: `POST /jmap/` also serves the management methods. Only discovery/client-configuration paths skip the Emporium login.
- Ban period (1 h) set in the first-start setup, so failed logins cannot ban the ingress address for good.
- Administrator username lowercase only; `AdminPassword` is install-only (rotation: Secret update plus pod restart).
