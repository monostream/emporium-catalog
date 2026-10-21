# Mealie

[Mealie](https://mealie.io/) is a self-hosted recipe manager and meal planner. Import recipes from any website by URL, organise them with tags, categories and cookbooks, plan the week, and turn a meal plan into a shopping list shared by the household.

## What you get

- Recipe import from URLs, images and other apps, a meal planner, shopping lists, and household sharing.
- PostgreSQL provisioned by Emporium (CloudNativePG) and a data volume for recipe images and backups.
- Single sign-on with your Emporium account; Emporium administrators become Mealie administrators.
- A local administrator for emergencies, with a generated password.

## Good to know

- **Single sign-on**: use "Sign in with Emporium" on the Mealie login page. Accounts are created at the first sign-in (switch off with "Create accounts at the first single sign-on"). Mealie identifies a user by the Emporium username (looked up as Mealie username, then email), so a changed email does not create a second account, and the Mealie name is the username. A Mealie account whose username (or, failing that, email) equals the Emporium username is adopted at the first single sign-on; with account creation switched off, create the Mealie account with the Emporium username. Mealie requires an email address for every single sign-on user, so an Emporium user without an email cannot sign in; set it in Emporium first. Members of the Emporium role `emporium-admin` are made Mealie administrators at every sign-in (and demoted when they lose the role). Set "Required role" to restrict who may sign in.
- **Local administrator**: Mealie always creates `changeme@example.com` with the public password `MyPassword` and offers no setting to change it. Emporium runs a small sidecar in the Mealie pod; the pod is not Ready (receives no traffic from the ingress) until the sidecar has replaced that account with username `mealie-local-admin`, the configured email and the generated password (at least 8 characters if you set your own; shorter passwords are rejected and the pod never becomes Ready). The sidecar keeps checking the current database (no state on disk), so a restored or reset database is handled too. If the default password no longer works, for example because it was changed already, the account is left untouched. Only clients inside the cluster network could reach the pod before it is Ready. Read the password with the command in the install notes (Secret `<app>-emporium-secrets`, key `AdminPassword`).
- **API and mobile apps**: the Mealie API areas used by mobile apps, Home Assistant and other clients (`/api/auth`, `recipes`, `households`, `groups`, `users`, `organizers`, `foods`, `units`, `comments`, recipe images) skip the Emporium login and are authenticated by Mealie with API tokens (User Profile > API Tokens). Everything else, including `/api/validators`, recipe attachments, `/api/admin` and `/api/explore`, stays behind the Emporium login. Mealie routes under the skipped areas that are public by design (sign-up when enabled, password reset, calendar feed tokens, shared recipe links) stay reachable.
- **Open registration** is off by default.

## Upstream

AGPL-3.0, <https://github.com/mealie-recipes/mealie>. The logo is the official Mealie icon.
