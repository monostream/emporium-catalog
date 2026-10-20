# documenso 0.1.x / 0.2.0 -> 0.3.0 (Emporium 0.5)

## Removed and renamed inputs

- No user inputs existed before. New inputs:
  - `SigningCertificate`, `SigningPassphrase` (section Signing certificate, optional secrets).
  - `NextauthSecret`, `EncryptionKey`, `EncryptionSecondaryKey` (section Security, generated at install).
- Removed: the `data` storage claim (`storage.data.*`). Documenso never wrote to it; uploads are stored in
  the database (`NEXT_PUBLIC_UPLOAD_TRANSPORT=database`).

## Database

- 0.1.x: bundled Bitnami postgresql subchart. Replaced: yes. Existing installs start with an empty
  database. Move the data with the installed-app blueprint
  (`docs/blueprints/migrate-installed-app-to-v0.5.md`): `pg_dump` from the old `<release>-postgresql-0` pod,
  restore into the new cluster.
- 0.2.0 (annotation-based native Postgres): the integration is named `postgres`, so the CloudNativePG
  cluster keeps its name `<release>-postgres`; no data move.
- Integration `postgres`: PostgreSQL 17, database and owner `documenso`, extensions `pgcrypto`, `pg_trgm`,
  8Gi grow-only.
- TLS: `sslmode=require` (encrypted; Prisma accepts the CloudNativePG certificate without a CA file).
  The URI is copied into the per-app Secret as `NEXT_PRIVATE_DATABASE_URL` (`secretKeys`, source `uri-sslmode-require`).

## Encryption keys (important when moving data)

Documenso encrypts stored secrets (2FA, API tokens, signing data) with `NEXT_PRIVATE_ENCRYPTION_KEY` and
`NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY`. When you restore an old database, enter the old values in the
`EncryptionKey`, `EncryptionSecondaryKey` and `NextauthSecret` inputs at install instead of generating new ones.
Read them before uninstalling 0.1.x / 0.2.0 from the Secrets `<fullname>-encryption-key`,
`<fullname>-encryption-key-secondary` and `<fullname>-nextauth-secret` (they carry
`helm.sh/resource-policy: keep` and survive the uninstall; delete them afterwards). Note that 0.1.x
regenerated the secondary key on every upgrade, so data encrypted with an older secondary key may already be unreadable.

## Data volumes

- The old `data` claim (`<release>-documenso-data` or the Emporium storage claim) held nothing. It can be
  deleted after the upgrade.

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- Generated keys and the optional signing certificate: `<app>-emporium-secrets`, keys `NEXTAUTH_SECRET`,
  `NEXT_PRIVATE_ENCRYPTION_KEY`, `NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY`,
  `NEXT_PRIVATE_SIGNING_LOCAL_FILE_CONTENTS`, `NEXT_PRIVATE_SIGNING_PASSPHRASE`, `NEXT_PRIVATE_DATABASE_URL`.
- SMTP password and OIDC client secret: by `secretKeyRef` to the integration outputs.
- No plaintext secrets remain in values.

## Behaviour changes

- Skip paths: `/api/*` only (`/#/*` was dropped: fragments never reach the server).
  External signers open `/sign/<token>` links; with access `authenticated` they need an Emporium login.
  Choose access `public` at install if people outside your organisation sign documents (Documenso has its own login).
- OIDC button label is "Emporium".
- No `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations from the chart.
