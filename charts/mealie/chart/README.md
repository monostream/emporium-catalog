# Mealie

[Mealie](https://mealie.io/) is a self-hosted recipe manager and meal planner. Import recipes from any website by URL, organise them with tags, categories and cookbooks, plan the week, and turn a meal plan into a shopping list shared by the household.

## What you get

- Recipe import from URLs, images and other apps, a meal planner, shopping lists, and household sharing.
- PostgreSQL provisioned by Emporium (CloudNativePG) and a data volume for recipe images and backups.
- Single sign-on with your Emporium account; Emporium administrators become Mealie administrators.
- A local administrator for emergencies, with a generated password.

## Good to know

- **Single sign-on**: use "Sign in with Emporium" on the Mealie login page. Accounts are created at the first sign-in (switch off with "Create accounts at the first single sign-on"). Mealie identifies a user by the Emporium username (looked up as Mealie username, then email), so a changed email does not create a second account, and the Mealie name is the username. A Mealie account whose username (or, failing that, email) equals the Emporium username is adopted at the first single sign-on; with account creation switched off, create the Mealie account with the Emporium username. Mealie requires an email address for every single sign-on user, so an Emporium user without an email cannot sign in; set it in Emporium first. Members of the Emporium role `emporium-admin` are made Mealie administrators at every sign-in (and demoted when they lose the role). Set "Required role" to restrict who may sign in.
- **Local administrator**: Mealie always seeds `changeme@example.com` with the public password `MyPassword` and offers no setting to change it (and `ALLOW_PASSWORD_LOGIN=false` only hides the login form in this version, the API still accepts passwords). An init container with the Mealie image therefore runs on every pod start, before Mealie serves: it runs Mealie's own database init, then, directly in the database, replaces the default account (username `mealie-local-admin`, the configured email, the generated password) if its password still verifies against the public default, and does nothing otherwise. The default login therefore never exists on a served instance. A password you set must have at least 8 characters, otherwise the init container fails and the pod does not start. If the database is reset or restored while the pod keeps running, restart the pod. Read the password with the command in the install notes (Secret `<app>-emporium-secrets`, key `AdminPassword`).
- **Break-glass**: if single sign-on is down and the local password is lost, set a new one inside the pod (interactive, asks for the account email and the new password): `kubectl -n <ns> exec -it deploy/<release>-mealie -c mealie -- /opt/mealie/bin/python -m mealie.scripts.change_password`. `python -m mealie.scripts.make_admin` makes an existing account administrator.
- **API and mobile apps**: the Mealie API areas used by mobile apps, Home Assistant and other clients (`/api/auth`, `recipes`, `households`, `groups`, `users`, `organizers`, `foods`, `units`, `comments`, recipe images) skip the Emporium login and are authenticated by Mealie with API tokens (User Profile > API Tokens). Everything else, including `/api/validators`, recipe attachments, `/api/admin` and `/api/explore`, stays behind the Emporium login. Mealie routes under the skipped areas that are public by design (sign-up when enabled, password reset, calendar feed tokens, shared recipe links) stay reachable.
- **Open registration** is off by default.

## Upstream

AGPL-3.0, <https://github.com/mealie-recipes/mealie>. The logo is the official Mealie icon.
