# Mealie

[Mealie](https://mealie.io/) is a self-hosted recipe manager and meal planner. Import recipes from any website by URL, organise them with tags, categories and cookbooks, plan the week, and turn a meal plan into a shopping list shared by the household.

## What you get

- Recipe import from URLs, images and other apps, a meal planner, shopping lists, and household sharing.
- PostgreSQL provisioned by Emporium (CloudNativePG) and a data volume for recipe images and backups.
- Single sign-on with your Emporium account; Emporium administrators become Mealie administrators.
- A local administrator for emergencies, with a generated password.

## Good to know

- **Single sign-on**: use "Sign in with Emporium" on the Mealie login page. Accounts are created at the first sign-in (switch off with "Create accounts at the first single sign-on"). The account name is your Emporium username. Mealie requires an email address for every single sign-on user, so an Emporium user without an email cannot sign in; set it in Emporium first. Members of the Emporium role `emporium-admin` are made Mealie administrators at every sign-in (and demoted when they lose the role). Set "Required role" to restrict who may sign in.
- **Local administrator**: Mealie always creates `changeme@example.com` with the public password `MyPassword` and offers no setting to change it. Emporium runs a small sidecar in the Mealie pod that, as soon as the API answers, replaces that account with username `admin`, the configured email and the generated password, so the default login is never usable. Read the password with the command in the install notes (Secret `<app>-emporium-secrets`, key `AdminPassword`). A local account whose email equals an Emporium user's email is adopted by that user at the first single sign-on.
- **API and mobile apps**: `/api/*` skips the Emporium login so mobile apps, Home Assistant and other clients can use Mealie API tokens (User Profile > API Tokens). Mealie authenticates those requests itself. Everything else stays behind the Emporium login.
- **Open registration** is off by default.

## Upstream

AGPL-3.0, <https://github.com/mealie-recipes/mealie>. The logo is the official Mealie icon.
