# Collabora Online

Collabora Online is a full office suite in the browser: documents, spreadsheets, presentations and drawings, with real-time co-editing. It does not store files. A file host such as Nextcloud opens the document in Collabora, which edits it and saves it back. Your documents stay on your own Emporium.

## Features

- Word, Excel and PowerPoint formats (docx, xlsx, pptx) and OpenDocument formats, edited in the browser
- Several people edit the same document at once
- Works with every WOPI host: Nextcloud (Nextcloud Office app), ownCloud, Seafile and others
- Admin console with live sessions and memory use

## Perfect for

Teams that keep their files in Nextcloud and want to edit them without leaving the browser or sending them to a cloud office.

## Good to know

- **Edition**: this is the Collabora Online Development Edition (CODE), the free build of Collabora Online. Collabora describes it as made for testing, home use and small teams, without support, and states that it is **not recommended for production environments**; for production use the supported Collabora Online build from Collabora Productivity; the supported commercial build is Collabora Online (Collabora Productivity). Source code is MPL-2.0. The "Collabora" name and logo are marks of Collabora Productivity Ltd., used here only to name the product.
- **No accounts**: Collabora has no users. The access control is the list of WOPI hosts that may open documents (install form: apps in the same zone, plus additional host names). The admin console at `/browser/dist/admin/admin.html` has its own login (user and a generated password, see the install notes).
- **Public on purpose**: the WOPI host's server fetches `/hosting/discovery` and Collabora calls back to the host, without any browser; the users' browsers load the editor in an iframe from this host. The Emporium login cannot sit in front of that, so the app is installed as public and only the allowed WOPI hosts can open documents.
- **Connect Nextcloud**: install Collabora, then in Nextcloud install the "Nextcloud Office" app (richdocuments) and under Administration settings > Office choose "Use your own server" with the URL of this app. For a Nextcloud installed in Emporium, its own host must be reachable by Collabora without the Emporium login at `/index.php/apps/richdocuments/wopi/*` (see the Nextcloud chart notes).
- One pod: open documents live in its memory. Give it 1 GiB memory plus about 100 MiB per open document.
- If you run Emporium on plain ingress-nginx (not the gateway), the default 1 MiB request body limit can reject image uploads and conversions with 413; set `ingress.annotations: {nginx.ingress.kubernetes.io/proxy-body-size: 100m}` there. Do not set it on the gateway: it breaks websockets.
- The host list is not an SSRF sandbox: hosts you allow stay trusted by the server.
