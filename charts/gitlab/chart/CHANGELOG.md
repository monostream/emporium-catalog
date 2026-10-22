# 0.4.2

Published on 21 October 2026

- A first OpenID Connect sign-in is linked to an existing GitLab account with the same email only when Logto reports `email_verified: true` (GitLab itself does not check it). Users already linked keep signing in as before.
- Documented that `global.emporium.adminRole` is the Logto role name in the `roles` claim and cannot come from the oidc integration's `AdminScope` (the API scope `admin`).

# 0.4.1

Published on 20 October 2026

- Fixed the ingress `skipPaths` for Git over HTTP: one comma-free regex covering clone, push and LFS (`info/refs`, `git-upload-pack`, `git-receive-pack`, `info/lfs/`, `gitlab-lfs/objects/`) with or without `.git`; UI paths such as `/-/blob/...` still go through Glass.

# 0.4.0

Published on 20 October 2026

- Requires Emporium v0.5.0 (`emporium.yaml`); profiles `small` (default, one pod per service, no agent server) and `medium`.
- PostgreSQL is the `postgres` integration (CloudNativePG cluster `<release>-postgres`, PostgreSQL 18, as in 0.3.0).
- Redis is Emporium's `redis` integration (Valkey `<release>-redis`) instead of the bundled Valkey chart; object storage is the `objects` integration (RustFS `<release>-objects`, buckets created by Emporium) instead of the bundled RustFS chart and bucket Job. Existing installs start with empty Redis and object storage; see MIGRATION.md before uninstalling a 0.3.x install.
- Email through the optional `mail` SMTP integration (password by reference).
- The registry and the agent server have their own ingress integrations `registry` and `kas` (no glass: they authenticate with GitLab tokens), each with its own subdomain chosen at install (were `registry.<host>` and `kas.<host>`).
- TLS secrets, ingress class and annotations come from the ingress integrations; the paths GitLab authenticates itself are `skipPaths`. The nginx-only kas gRPC Ingress is off; agents connect over WebSocket.
- Removed the Object Storage Size field (now the size of the `objects` integration); Repository Storage Size can no longer change after the install.

# 0.3.0

Published on 19 October 2026

- gitlab from 10.4.1 to 10.5.0 (GitLab 19.5.0)
- Sign-in through Emporium's identity provider (Logto); members of the emporium-admin role become GitLab administrators automatically
- PostgreSQL from Emporium's CloudNativePG integration (PostgreSQL 18) instead of the removed bundled PostgreSQL
- Valkey replaces the removed bundled Redis, RustFS replaces the removed bundled MinIO; buckets are created automatically
- The bundled GitLab Runner is registered automatically with a runner authentication token; its CI jobs run unprivileged unless the new Privileged CI Jobs setting is on
- Breaking: data of 0.2.x installations is not migrated

# 0.2.86

Published on 19 October 2026

- Emporium values no longer hard-code global.ingress.class nginx

# 0.2.84

Published on 7 October 2026

- gitlab from 9.8.3 to 10.4.1

# 0.2.83

Published on 4 February 2026

- gitlab from 9.8.2 to 9.8.3

# 0.2.82

Published on 21 January 2026

- gitlab from 9.8.1 to 9.8.2

# 0.2.81

Published on 19 January 2026

- gitlab from 9.8.0 to 9.8.1

# 0.2.80

Published on 15 January 2026

- gitlab from 9.7.1 to 9.8.0

# 0.2.79

Published on 8 January 2026

- gitlab from 9.7.0 to 9.7.1

# 0.2.78

Published on 18 December 2025

- gitlab from 9.6.2 to 9.7.0

# 0.2.77

Published on 10 December 2025

- gitlab from 9.6.1 to 9.6.2

# 0.2.76

Published on 26 November 2025

- gitlab from 9.6.0 to 9.6.1

# 0.2.75

Published on 20 November 2025

- gitlab from 9.5.2 to 9.6.0

# 0.2.74

Published on 13 November 2025

- gitlab from 9.5.1 to 9.5.2

# 0.2.73

Published on 22 October 2025

- gitlab from 9.5.0 to 9.5.1

# 0.2.72

Published on 16 October 2025

- gitlab from 9.4.2 to 9.5.0

# 0.2.71

Published on 8 October 2025

- gitlab from 9.4.1 to 9.4.2

# 0.2.70

Published on 26 September 2025

- gitlab from 9.4.0 to 9.4.1

# 0.2.69

Published on 25 September 2025

- gitlab from 9.3.0 to 9.4.0

# 0.2.68

Published on 22 August 2025

- gitlab from 9.2.4 to 9.3.0

# 0.2.67

Published on 20 August 2025

- gitlab from 9.2.2 to 9.2.4

# 0.2.66

Published on 14 August 2025

- gitlab from 9.2.1 to 9.2.2

# 0.2.65

Published on 23 July 2025

- gitlab from 9.2.0 to 9.2.1

# 0.2.64

Published on 17 July 2025

- gitlab from 9.1.2 to 9.2.0

# 0.2.63

Published on 9 July 2025

- gitlab from 9.1.1 to 9.1.2

# 0.2.62

Published on 26 June 2025

- gitlab from 9.1.0 to 9.1.1

# 0.2.61

Published on 19 June 2025

- gitlab from 9.0.2 to 9.1.0

# 0.2.60

Published on 12 June 2025

- gitlab from 9.0.1 to 9.0.2

# 0.2.59

Published on 21 May 2025

- gitlab from 9.0.0 to 9.0.1

# 0.2.58

Published on 17 May 2025

- gitlab from 8.11.2 to 9.0.0

# 0.2.57

Published on 12 May 2025

- gitlab from 8.11.1 to 8.11.2

# 0.2.56

Published on 23 April 2025

- gitlab from 8.11.0 to 8.11.1

# 0.2.55

Published on 17 April 2025

- gitlab from 8.10.4 to 8.11.0

# 0.2.54

Published on 9 April 2025

- gitlab from 8.10.3 to 8.10.4

# 0.2.53

Published on 2 April 2025

- gitlab from 8.10.1 to 8.10.3

# 0.2.52

Published on 26 March 2025

- gitlab from 8.10.0 to 8.10.1

# 0.2.51

Published on 20 March 2025

- gitlab from 8.9.2 to 8.10.0

# 0.2.50

Published on 13 March 2025

- gitlab from 8.9.1 to 8.9.2

# 0.2.49

Published on 26 February 2025

- gitlab from 8.9.0 to 8.9.1

# 0.2.48

Published on 20 February 2025

- gitlab from 8.8.2 to 8.9.0

# 0.2.47

Published on 12 February 2025

- gitlab from 8.8.1 to 8.8.2

# 0.2.46

Published on 22 January 2025

- gitlab from 8.8.0 to 8.8.1

# 0.2.45

Published on 16 January 2025

- gitlab from 8.7.4 to 8.8.0

# 0.2.44

Published on 15 January 2025

- gitlab from 8.7.3 to 8.7.4

# 0.2.43

Published on 9 January 2025

- gitlab from 8.7.2 to 8.7.3

# 0.2.42

Published on 27 December 2024

- gitlab from 8.7.1 to 8.7.2

# 0.2.41

Published on 21 December 2024

- gitlab from 8.7.0 to 8.7.1

# 0.2.40

Published on 19 December 2024

- gitlab from 8.6.2 to 8.7.0

# 0.2.39

Published on 11 December 2024

- gitlab from 8.6.1 to 8.6.2

# 0.2.38

Published on 26 November 2024

- gitlab from 8.6.0 to 8.6.1

# 0.2.37

Published on 21 November 2024

- gitlab from 8.5.2 to 8.6.0

# 0.2.36

Published on 13 November 2024

- gitlab from 8.5.1 to 8.5.2

# 0.2.35

Published on 23 October 2024

- gitlab from 8.5.0 to 8.5.1

# 0.2.34

Published on 17 October 2024

- gitlab from 8.4.2 to 8.5.0

# 0.2.33

Published on 10 October 2024

- gitlab from 8.4.1 to 8.4.2

# 0.2.32

Published on 1 October 2024

- gitlab from 8.3.2 to 8.4.1

# 0.2.31

Published on 12 September 2024

- gitlab from 8.3.1 to 8.3.2

# 0.2.30

Published on 22 August 2024

- gitlab from 8.3.0 to 8.3.1

# 0.2.29

Published on 15 August 2024

- gitlab from 8.2.2 to 8.3.0

# 0.2.28

Published on 7 August 2024

- gitlab from 8.2.1 to 8.2.2

# 0.2.27

Published on 24 July 2024

- gitlab from 8.2.0 to 8.2.1

# 0.2.26

Published on 18 July 2024

- gitlab from 8.1.2 to 8.2.0

# 0.2.25

Published on 10 July 2024

- gitlab from 8.1.1 to 8.1.2

# 0.2.24

Published on 26 June 2024

- gitlab from 8.1.0 to 8.1.1

# 0.2.23

Published on 20 June 2024

- gitlab from 8.0.2 to 8.1.0

# Updates Thursday, 13-Jun-2024 07:38:14 UTC
- gitlab from 8.0.1 to 8.0.2

# Updates Wednesday, 22-May-2024 17:01:50 UTC
- gitlab from 8.0.0 to 8.0.1

# Updates Thursday, 16-May-2024 17:01:44 UTC
- gitlab from 7.11.2 to 8.0.0

# Updates Wednesday, 08-May-2024 13:13:41 UTC
- gitlab from 7.11.1 to 7.11.2

# Updates Wednesday, 24-Apr-2024 17:01:43 UTC
- gitlab from 7.11.0 to 7.11.1

# Updates Thursday, 18-Apr-2024 17:01:47 UTC
- gitlab from 7.10.3 to 7.11.0

# Updates Monday, 15-Apr-2024 17:01:44 UTC
- gitlab from 7.10.2 to 7.10.3

# Updates Thursday, 11-Apr-2024 08:56:25 UTC
- gitlab from 7.10.1 to 7.10.2

