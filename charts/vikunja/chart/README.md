# Vikunja

Vikunja is a to-do and project manager for people and teams. Keep tasks in lists, move them across a kanban board, plan them on a gantt chart or filter them in a table, and share projects with the people you work with.

## Features

- Projects with sub-projects, labels, priorities, due dates, reminders, repeating tasks, attachments and comments
- List, kanban, gantt and table views, saved filters and project sharing with teams or by link
- CalDAV, so tasks show up in your calendar and task apps, plus a REST API and mobile apps
- Import from Todoist, Trello, Microsoft To Do and others
- Single sign-on through Emporium: every Emporium user gets their own account at the first sign-in

## Perfect for

Households, clubs and small teams who want one private place for to-dos and projects, without handing the data to a hosted service.

## Good to know

- **Single sign-on.** The Vikunja username is the Emporium (Logto) username and the display name is taken from the Emporium profile. Vikunja requires an email address for every account: an Emporium user without an email (an administrator sets it in Emporium) cannot sign in by single sign-on and sees "No email address was provided by the OpenID provider". Accounts created by single sign-on are regular users: the free edition of Vikunja has no administrator role, so Emporium administrators are not mapped.
- **Local administrator.** A local account (default `admin`) is created once, shortly after the first install, by a Job; its password is in the app's Secret (shown in the install notes). Local login stays on so you can get in when single sign-on is unavailable. A single sign-on user with the same username as an existing local account cannot sign in, so keep the local account name different from Emporium usernames.
- **Registration** of new local accounts is off by default (input "Allow self-registration").
- **Paths that skip the Emporium login:** `/api` (web app calls, mobile apps and API tokens), `/dav` and `/.well-known/caldav` (CalDAV), and `/share` (link shares). Vikunja authenticates them itself.
- Attachments are stored on a volume; tasks and users are in PostgreSQL.
