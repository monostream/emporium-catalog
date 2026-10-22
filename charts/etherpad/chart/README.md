# Etherpad

Etherpad is a real-time collaborative editor: several people type in the same document at once and see every change as it happens, each in their own colour.

## Features

- Live co-editing with author colours, chat and a full revision history with a time slider
- Rich text, lists, headings and fonts; import and export as HTML, plain text and Word (DOCX)
- Every pad has its own address: start a new document by typing a name, share it by sending the link
- Read-only links for guests and an `/admin` page for settings, plugins and pad management
- Stores all pads in PostgreSQL, managed by Emporium, over a TLS connection verified with the database's CA

## Perfect for

Meeting notes, quick drafts and shared checklists that a team wants to write together without accounts, installs or formatting fuss.

## Good to know

- No separate Etherpad account is needed: access is controlled by the Emporium login. Etherpad has no generic OpenID Connect login without a plugin, and plugins are built into the image, so this chart does not offer single sign-on inside Etherpad. Everybody who may open the app can create and edit every pad and picks their own display name in the pad.
- To share pads with people outside Emporium, open the app's access settings and make the app public; anyone with a pad link can then edit it.
- `/admin` (settings, plugins, pad management) signs in with the user `admin`. The generated password is in the app's Secret (`AdminPassword`); see the notes after install for the command.
- Plugins can be installed from `/admin`, but they live in the container and are lost when the pod restarts. Pads and revisions are kept in PostgreSQL.
- The Etherpad icon is the official logo (Apache-2.0 project).
