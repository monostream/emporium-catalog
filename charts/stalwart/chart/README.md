# Stalwart Mail Server

Stalwart is an all-in-one mail and collaboration server written in Rust: SMTP, IMAP, POP3, JMAP, ManageSieve, CalDAV, CardDAV and WebDAV, with a built-in spam filter, DKIM/SPF/DMARC and a web administration. This chart runs the official `stalwartlabs/stalwart` image (v0.16 series) on a single volume (RocksDB), with the web administration behind the Emporium ingress.

The icon is the official Stalwart logo mark (`img/logo-red.svg` of the upstream repository, cropped to the symbol).

## What you get

- The web administration at `https://<host>/admin` (accounts, groups, mailing lists, domains, DKIM keys, queues, reports, logs, settings).
- The first mail domain you entered at install, with DKIM keys already generated.
- JMAP, CalDAV/CardDAV/WebDAV and the client auto-configuration endpoints on the same host, protected by Stalwart's own logins.
- Mail on a cluster-internal Service only (SMTP, submission, IMAP, POP3, ManageSieve) until you decide to expose it, see "Running a real mail server".

## First start and sign-in

On a fresh volume Stalwart starts in bootstrap mode. A second container in the pod (`provision`) completes the setup through Stalwart's bootstrap API: server host name = the web host, first domain = your input, no ACME (Emporium terminates TLS for the web endpoints), RocksDB on the volume, logs on stdout. Stalwart then writes `config.json` to the volume and the main container restarts into normal mode, which takes about a minute; the pod is ready when the mail listeners are up. Later starts skip all of this.

Sign in at `/admin` with the administrator username (default `admin`) and the generated password from the app's Secret:

    kubectl -n <namespace> get secret <release>-emporium-secrets -o jsonpath='{.data.AdminPassword}' | base64 -d

This administrator is Stalwart's "recovery admin" (`STALWART_RECOVERY_ADMIN`). It works at any time, also if the directory is empty, and has no mailbox. Create your own accounts under Directory > Accounts; give a user the "Admin" role there if they should manage the server. The setup also created `admin@<domain>`, an account with a random password nobody has seen; reset its password in the web admin or delete it.

## Good to know

- **Single sign-on:** not offered. Stalwart's OpenID Connect support is a directory backend that validates access tokens that mail and JMAP clients bring from an external provider (`OAUTHBEARER`); it has no "sign in with ..." button for the web administration and does not start an OIDC flow itself. The Community edition and this chart therefore ship without an `oidc` integration. The web administration sits behind the Emporium login (`access: authenticated`) in addition to Stalwart's own sign-in.
- **Enterprise features** (marked with a lock in the web administration, for example the dashboard, multi-tenancy, SCIM and masked addresses) need a Stalwart Enterprise licence and are not part of this chart's scope. Everything described here works in the AGPL-3.0 community edition.
- **Paths that skip the Emporium login** (`skipPaths`): only discovery and client configuration: `/.well-known/*` (JMAP, OAuth and OpenID discovery, CalDAV/CardDAV redirects, autoconfig), `/autodiscover/*`, `/mail/config-v1.1.xml` and `/auth/*` (OAuth token, device, userinfo and JWKS endpoints). The web administration (`/admin`, `/account`, `/login`) and the APIs stay behind the Emporium login.
- **JMAP and CalDAV/CardDAV/WebDAV are not reachable without the Emporium login by default.** `POST /jmap/` is also the management API: with an administrator credential (including the one from the app's Secret, which accepts Basic auth) it can create accounts and change every setting (`x:Account/set`, `x:SystemSettings/set`). Skipping `/jmap/*` would therefore let anyone holding the administrator password manage the server without an Emporium session, and unauthenticated failures there would count against the ingress address. Emporium's `skipPaths` are fixed per chart, so there is no switch for it. IMAP/SMTP clients are not affected (they use the mail ports, see below). If you need JMAP or DAV clients over the web host, add `/jmap/*` and `/dav/*` to the ingress skip paths of a copy of the chart and accept that exposure, or reach them from inside the cluster through the Service.
- **Failed logins and the ingress address:** Stalwart sees the ingress as the client of web requests (it does not read `X-Forwarded-For` unless the HTTP listener is set to), and bans an address after 100 failed logins per day. Stalwart's default ban never expires, so the chart sets a ban period of one hour (`config.banPeriodMinutes`, only while none is configured) for authentication, abuse, loitering and scan bans; later changes in Settings > Security are kept. Forwarded headers are not enabled: that is only safe when the ingress overwrites a client-supplied `X-Forwarded-For`. The "Proxy trusted networks" setting is for the PROXY protocol, not for HTTP forwarding; do not use it behind the Emporium ingress.
- **Rotating the administrator password:** the password is read from the Secret when the pod starts. Update `AdminPassword` in the app's Secret and restart the pod; until then the old password keeps working. The administrator username must be lowercase (Stalwart lowercases login names).
- **The web interface is downloaded at the first start** by Stalwart itself from GitHub (`github.com/stalwartlabs/webui`, refreshed on a schedule), and spam rules and geo data from GitHub too. The pod needs outbound HTTPS to GitHub; without it `/admin` answers 404 until the download works.
- **The container needs `NET_BIND_SERVICE` and `allowPrivilegeEscalation: true`:** the binary carries a file capability for ports below 1024, and the kernel refuses to start it when the capability is missing from the bounding set. Everything else is dropped, the root file system is read-only and the process runs as UID 2000.
- **Storage:** one volume holds `config.json` (`etc/`), the RocksDB store with mail, settings and search index (`data/`). Stalwart allows one process on it, so there is one replica and the Deployment recreates the pod on updates. PostgreSQL (through the Emporium postgres integration) is not wired in this release.

## Running a real mail server

The chart installs the web administration and keeps the mail ports internal. For real mail:

1. **Expose the mail ports.** Set `mail.service.enabled=true` and choose `mail.service.type` (`LoadBalancer` or `NodePort`; default `ClusterIP`). The Service carries 25 (SMTP), 465 (SMTPS), 587 (submission), 143/993 (IMAP/IMAPS), 110/995 (POP3/POP3S) and 4190 (ManageSieve). Use `mail.service.externalTrafficPolicy: Local` with a load balancer so Stalwart sees real client addresses. Alternatively publish the ports with `hostPort` on a dedicated node. Expose only what you use; SMTP on 25 must be reachable from the internet to receive mail.
2. **Outbound port 25** must be allowed by your cloud provider (many block it by default), and the sending IP needs a **reverse DNS (PTR)** record that matches the server host name (the web host, or set `config.serverHostname`).
3. **Certificates for the mail ports.** Emporium's ingress certificate does not reach the mail listeners. In Stalwart, add a certificate for the server host name (Settings > TLS: an ACME provider, or upload a certificate that your cluster issues, for example with cert-manager) and set it as the default. Until then, clients see a self-signed certificate.
4. **DNS records for your domain:** MX, SPF, DKIM, DMARC and the autoconfig/SRV records. Open Domains > Domains > your domain in the web administration: the domain shows the exact zone file (DKIM public keys included). Set a DNS provider under the domain's DNS management to let Stalwart publish and rotate them automatically.
5. **Upgrading from v0.15** is a migration, not a chart upgrade (see Stalwart's `UPGRADING/v0_16.md`); this chart starts v0.16 fresh.

## Values worth knowing

| Value | Default | Meaning |
|---|---|---|
| `config.defaultDomain` | `example.org` | First mail domain (install only, input "Mail domain") |
| `config.banPeriodMinutes` | `60` | How long a ban lasts (Stalwart's default is no expiry) |
| `config.serverHostname` | web host | SMTP greeting, TLS names, MX target in the zone file |
| `admin.username` | `admin` | Administrator username (install only) |
| `mail.service.enabled` / `.type` | `false` / `ClusterIP` | Service with the mail ports |
| `persistence.size` | `10Gi` | Volume for mail and settings (grows only) |

Stalwart is licensed AGPL-3.0 (the chart records `AGPL-3.0-only`); the Enterprise edition is separate and needs a licence key from Stalwart Labs.
