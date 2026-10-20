Emporium app used for integration testing of the provisioning integrations.

Like the Integration Test app, it serves a static hello page behind Emporium's login on three hosts. In addition it gets:

- a PostgreSQL database (CloudNativePG); an init container connects to it before the app starts, so the install only becomes ready when the database works;
- optionally a Redis (Valkey) instance, passed to the app as environment variables;
- optionally a data volume, mounted at `/data`.

The Emporium end-to-end suite installs it to test keeping a database on uninstall (retain data) and refusing a database name that belongs to someone else.
