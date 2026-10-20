# 2.0.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`).
- Breaking: replaces the Bitnami `supabase` chart 5.3.6 (deprecated, images no longer pullable) with the supabase-community chart `supabase` 0.8.0 and its bundled `supabase/postgres` 17.6 database (documented exception to the postgres integration). **Existing installs start with an empty database**; data moves by dump and restore (MIGRATION.md).
- One host: Studio at `/` behind the Emporium login (default access: admins), the Supabase APIs through Kong with Supabase's own key auth. The `api.<host>` name is gone.
- Uploaded files go to the `files` objectStorage integration (S3, bucket `supabase`) instead of a volume.
- Data volumes are storage integrations: `db` (8Gi, also holds the pgsodium root key), `functions` and `snippets` (1Gi each), all grow-only.
- JWT secret, database password, Realtime, Postgres Meta, S3 protocol and Kong dashboard credentials are generated inputs delivered by reference from the per-app Secret. Helm creates Secret `supabase-keys` empty; a Job (not a Helm hook, get/update on that Secret only) signs the anon and service_role keys once and copies the SMTP credentials on every install and upgrade. Auth waits until the SMTP copy is current. The database password is limited to URI-safe characters.
- SMTP from the optional `mail` integration; without it new users are confirmed automatically.
- New inputs: Site URL, additional redirect URLs, disable sign-ups, OpenAI API key for Studio. Removed: `StorageSize`, `DatabaseSize`.
- Components and `small`/`medium` profiles with resources on every container; not deployed: Logflare/Vector, imgproxy, MinIO.
- Fixes the pgsodium config copy on volumes that are not empty (lost+found).

# 1.0.55

Published on 19 October 2026

- Merge the duplicate auth keys in values.emporium.yaml: the auth image override and the SMTP settings were dropped before
- SMTP settings (including the username instead of the sender address as SMTP user) are passed to auth through a <release>-smtp Secret
- Auth image supabase/gotrue v2.159.1, the version the subchart was built for (was v2.70.0, never applied)
- Auth runs its migrations from /usr/local/etc/auth/migrations, where the official image ships them (the subchart default points at the Bitnami image layout)
- DatabaseSize sets supabase.postgresql.primary.persistence.size (the old path had no effect)

# 1.0.53

Published on 29 August 2024

- supabase from 5.3.5 to 5.3.6

# 1.0.52

Published on 27 August 2024

- supabase from 5.3.4 to 5.3.5

# 1.0.51

Published on 14 August 2024

- supabase from 5.3.3 to 5.3.4

# 1.0.50

Published on 25 July 2024

- supabase from 5.3.2 to 5.3.3

# 1.0.49

Published on 25 July 2024

- supabase from 5.3.1 to 5.3.2

# 1.0.48

Published on 17 July 2024

- supabase from 5.3.0 to 5.3.1

# 1.0.47

Published on 9 July 2024

- supabase from 5.2.9 to 5.3.0

# 1.0.46

Published on 4 July 2024

- supabase from 5.2.8 to 5.2.9

# 1.0.45

Published on 4 July 2024

- supabase from 5.2.7 to 5.2.8

# 1.0.44

Published on 19 June 2024

- supabase from 5.2.5 to 5.2.7

# 1.0.43

Published on 18 June 2024

- supabase from 5.2.3 to 5.2.5

# Updates Friday, 07-Jun-2024 08:03:07 UTC
- supabase from 5.2.0 to 5.2.3

# Updates Wednesday, 29-May-2024 17:03:52 UTC
- supabase from 5.1.1 to 5.2.0

# Updates Wednesday, 22-May-2024 08:02:22 UTC
- supabase from 5.1.0 to 5.1.1

# Updates Tuesday, 21-May-2024 17:03:10 UTC
- supabase from 5.0.0 to 5.1.0

# Updates Tuesday, 21-May-2024 08:03:06 UTC
- supabase from 4.0.8 to 5.0.0

# Updates Saturday, 18-May-2024 08:04:02 UTC
- supabase from 4.0.7 to 4.0.8

# Updates Tuesday, 14-May-2024 08:02:03 UTC
- supabase from 4.0.6 to 4.0.7

# Updates Friday, 10-May-2024 17:02:40 UTC
- supabase from 4.0.5 to 4.0.6

# Updates Wednesday, 01-May-2024 08:03:02 UTC
- supabase from 4.0.4 to 4.0.5

# Updates Tuesday, 30-Apr-2024 17:03:57 UTC
- supabase from 4.0.3 to 4.0.4

# Updates Wednesday, 24-Apr-2024 17:02:43 UTC
- supabase from 4.0.1 to 4.0.3

# Updates Monday, 15-Apr-2024 17:02:14 UTC
- supabase from 4.0.0 to 4.0.1

# Updates Thursday, 11-Apr-2024 09:04:59 UTC
- supabase from 3.0.1 to 4.0.0

