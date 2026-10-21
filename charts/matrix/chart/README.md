# Matrix (Synapse + Element)

Matrix is an open, end-to-end encrypted chat network. This chart runs your own Matrix homeserver (Synapse) together with the Element web client on one address: rooms, direct messages, file sharing, voice and video calls (through the Element apps), all on your own server.

## Features

- Synapse homeserver with PostgreSQL and a persistent media store
- Element web client on the same address, ready to use, with end-to-end encrypted rooms
- Single sign-on through Emporium: "Continue with Emporium" creates your Matrix account at the first sign-in
- Works with the Element and Element X apps and any other Matrix client
- Private by default: federation with other Matrix servers is off, registration is closed

## Perfect for

Teams, families and communities who want their own private chat server with encrypted rooms and apps on every device.

## Good to know

- **Sign-in.** Open the address and choose "Continue with Emporium". Your Matrix id is `@<emporium username>:<host>`. Emporium (Logto) usernames become Matrix ids; an account created another way with the same name blocks that user's single sign-on.
- **Administrator.** Synapse cannot make administrators from single sign-on. Create the first one with the registration shared secret (generated at install, held in the app's Secret); registration stays closed. The command is printed after install:
  `kubectl exec deploy/<release>-synapse -- register_new_matrix_user -u admin -a -c /config/homeserver.yaml http://localhost:8008`.
  That account signs in with its password in Element (password login is on by default) and can then promote others from the Synapse admin API.
- **Emporium login.** The Element page itself is behind the Emporium login (set the access to public if anyone should open it). `/_matrix`, `/_synapse` and `/.well-known/matrix` skip it, because Matrix apps, bridges and other servers authenticate there with tokens, and the single sign-on callback returns there.
- **Server name.** The Matrix server name is the host name of the install. It becomes part of every user id and room id, so it cannot be changed later; reinstall to use another host.
- **Federation.** Off by default. Turning it on opens `/_matrix/federation` and serves `/.well-known/matrix/server` on this host, so other servers find it on port 443. It needs a public DNS name and certificate. To use a short server name (`example.com` instead of `chat.example.com`) delegate from the apex yourself with a `/.well-known/matrix/server` there.
- **Database.** PostgreSQL is created with the C locale that Synapse requires.
- **Calls.** Element Call and group voice/video need a LiveKit or TURN service, which this chart does not include.
