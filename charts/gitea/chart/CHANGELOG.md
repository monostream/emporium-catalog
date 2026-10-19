# 0.1.0

Published on 19 October 2026

- PostgreSQL is provided by Emporium's native Postgres integration (CloudNativePG, PostgreSQL 17) instead of the bundled postgresql-ha cluster (3 PostgreSQL pods plus pgpool); the password comes from the CloudNativePG app secret. Requires Emporium v0.5.0. Existing data in the bundled database is not migrated.
- Admin user, Emporium OIDC login and app.ini settings (registration disabled, Actions, Swagger off) are nested under gitea.gitea so the Gitea chart applies them. Before, they were ignored: installs got the chart's default admin account and open registration.
- Connects to PostgreSQL with SSL_MODE require (CloudNativePG always serves TLS)

# 0.0.37

Published on 7 October 2026

- gitea from 12.5.0 to 12.7.0

# 0.0.36

Published on 24 January 2026

- gitea from 12.4.0 to 12.5.0

# 0.0.35

Published on 6 October 2025

- gitea from 12.3.0 to 12.4.0

# 0.0.34

Published on 25 September 2025

- gitea from 12.2.0 to 12.3.0

# 0.0.33

Published on 19 August 2025

- gitea from 12.1.3 to 12.2.0

# 0.0.32

Published on 9 August 2025

- gitea from 12.1.2 to 12.1.3

# 0.0.31

Published on 30 July 2025

- gitea from 12.1.1 to 12.1.2

# 0.0.30

Published on 27 June 2025

- gitea from 12.1.0 to 12.1.1

# 0.0.29

Published on 16 June 2025

- gitea from 12.0.0 to 12.1.0

# 0.0.28

Published on 17 May 2025

- gitea from 11.0.1 to 12.0.0

# 0.0.27

Published on 27 March 2025

- gitea from 11.0.0 to 11.0.1

# 0.0.26

Published on 2 March 2025

- gitea from 10.6.0 to 11.0.0

# 0.0.25

Published on 10 November 2024

- gitea from 10.5.0 to 10.6.0

# 0.0.24

Published on 18 October 2024

- gitea from 10.4.1 to 10.5.0

# 0.0.23

Published on 11 September 2024

- gitea from 10.4.0 to 10.4.1

# 0.0.22

Published on 21 July 2024

- gitea from 10.3.0 to 10.4.0

# 0.0.21

Published on 7 July 2024

- gitea from 10.2.0 to 10.3.0

# Updates Friday, 07-Jun-2024 08:01:23 UTC
- gitea from 10.1.4 to 10.2.0

# Updates Tuesday, 16-Apr-2024 17:01:59 UTC
- gitea from 10.1.3 to 10.1.4

