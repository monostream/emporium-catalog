# integration-test-full 0.1.0 (Emporium 0.5)

New chart; there are no 0.4 installs to migrate.

## Removed and renamed inputs

None.

## Database

New `postgres` integration (CloudNativePG cluster `<release>-postgres`, PostgreSQL 17, database
and owner `app`, 1Gi grow-only, no extensions). The `check-postgres` init container connects with
`psql` (`PGSSLMODE=require`; user and password by `secretKeyRef` from the CloudNativePG app Secret)
before the app starts. Used by the e2e retain-data and foreign-cluster tests (`E2E_POSTGRES_APP`).

## Hostnames

Same as integration-test: `<subdomain>.<zone>`, `<subdomain>-second.<zone>`,
`<subdomain>-third.<zone>`.

## TLS secret

The integration's `TLSSecretName` (zone dependent).

## Secrets

None of its own. PostgreSQL and Redis credentials are read by reference from the provider Secrets.

## Behaviour

- Optional `redis` integration (Valkey, cache mode, 32Mi): `REDIS_HOST`, `REDIS_PORT`,
  `REDIS_PASSWORD` (by reference) in the app container; nothing uses them.
- Optional `data` storage integration (1Gi): mounted at `/data`.
- The e2e suite leaves optional integrations off, so its runs provision only the database.
