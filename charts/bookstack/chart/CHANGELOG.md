# 0.1.0

- New chart: BookStack 26.9.2 (community image `solidnerd/bookstack`, MIT, runs as www-data on port 8080; BookStack publishes no image of its own), requires Emporium v0.5.0.
- MariaDB 11.4 (official `mariadb` image) as a chart-local StatefulSet on its own volume; Emporium has no MySQL provider. Passwords and the application key are generated into the per-app Secret and delivered by reference.
- Behind the Emporium login (`access: authenticated`); only the REST API (`/api/*`, API tokens) skips it.
- No single sign-on: BookStack accepts only RS256-signed ID tokens, Logto signs with ES384 (BookStack issues #5390, #5915).
- BookStack's public default login `admin@admin.com` / `password` is replaced before the web server starts, by an init container, with the configured email and the generated password.
- Fail closed: the bootstrap init container is always rendered and `admin.existingSecret` is required; bootstrap refuses to start the pod when the administrator password is missing, shorter than 8 characters or the public default `password`, or the email is invalid.
