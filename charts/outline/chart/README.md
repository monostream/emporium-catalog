# Outline

Outline is a fast, collaborative wiki for your team: write documents together in real time, organise them in collections and find anything with instant search.

## Features

- Real-time collaborative editing with Markdown shortcuts, comments and document history
- Collections, nested documents, templates and powerful search
- Share documents or whole collections with a public link, or keep them private
- Rich embeds (diagrams, videos, design files), import from Markdown, Word, Notion and Confluence exports
- REST API and webhooks for integrations
- Single sign-on through Emporium: everyone in your Emporium sees the same workspace

## Perfect for

Teams and organisations who want a private, good-looking place for their handbook, runbooks, meeting notes and project documentation.

## Licence

Outline is distributed under the Business Source License 1.1 (converting to Apache-2.0 on 2030-10-12). Self-hosting for your own use is explicitly allowed; the only restriction is offering Outline as a commercial "Document Service" to third parties who create their own teams and documents. This chart installs the unmodified upstream image; whether a given deployment is allowed depends on how you use it, so check the licence if you plan to offer Outline to third parties.

## Good to know

- **An email address is required.** Outline creates accounts from the email claim; Emporium users without an email cannot sign in with SSO. Emporium administrators set emails on users.
- **The first user becomes the administrator.** Outline has no role mapping from the identity provider. The first person who signs in creates the workspace and is its administrator; later users join as members and can be promoted under Settings > Members. The installing administrator should sign in first, before anyone else is told the URL.
- There is no local administrator account: Outline only offers single sign-on (or email links). The first SSO user is the administrator, so sign in yourself right after the install.
- Attachments and images are stored on a persistent volume (not S3), so Outline runs as a single instance.
- API keys (Settings > API) and public share links (`/s/...`) are reachable without the Emporium login.
- Outgoing email (invitations, notification digests) needs an SMTP configuration chosen at install.
