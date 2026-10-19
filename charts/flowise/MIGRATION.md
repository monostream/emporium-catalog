# flowise 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

- `Username`, `Password`: deleted. Flowise 3 ignores `FLOWISE_USERNAME`/`FLOWISE_PASSWORD` except to
  claim an instance upgraded from Flowise 2; accounts live in Flowise itself.
- New generated secret inputs (section Security): `JwtAuthTokenSecret`, `JwtRefreshTokenSecret`,
  `ExpressSessionSecret`, `TokenHashSecret`. Existing sessions end once on upgrade.

## Database

- Default unchanged: SQLite at `/data/.flowise/database.sqlite` on the data volume.
- New optional `db` postgres integration (`required: false`, install toggle, PostgreSQL 17, database
  and owner `flowise`, 5Gi grow-only, no extensions). Turning it on for an existing install is not
  possible (the toggle is install-time); there is no SQLite -> Postgres migration in the chart.
- TLS to the database: plain. Flowise's `DATABASE_SSL=true` verifies against the system CAs and
  fails on the CloudNativePG CA; the in-cluster pg_hba accepts plain connections.

## Data volumes

- `data` (storage integration, default 1Gi, grow-only), mounted at `/data`: SQLite database,
  encryption key (`/data/.flowise/encryption.key`), logs and uploaded blobs. Keep it on uninstall
  if you want the flows and credentials back.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- Session/token secrets: `<app>-emporium-secrets`, keys `JWT_AUTH_TOKEN_SECRET`,
  `JWT_REFRESH_TOKEN_SECRET`, `EXPRESS_SESSION_SECRET`, `TOKEN_HASH_SECRET`.
- Postgres password: read from the CloudNativePG app Secret by `secretKeyRef`.
- No plaintext secrets remain (the old `Password` input was plaintext).

## Behaviour changes

- Skip paths: `/api/*` (API-key authenticated prediction API); `/#/*` dropped.
- The unused `lookup` helper is gone (preview gets a manifest diff).
- No `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations from the chart.
