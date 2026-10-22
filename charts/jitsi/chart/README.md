# Jitsi Meet

Jitsi Meet is open-source video conferencing: start a meeting from a link, with no account or app to install for the people you invite. Audio, video, screen sharing, chat and a moderator-controlled lobby, all on your own infrastructure.

## Features

- Meetings in the browser (and the Jitsi mobile apps), no installation for participants
- HD video, screen sharing, chat, polls, reactions, raise hand and breakout rooms
- Pre-join screen to check camera and microphone, moderator lobby and room passwords
- Your own server: conversations and media stay on your infrastructure
- Includes the whole stack: web, XMPP server (Prosody), conference focus (Jicofo) and videobridge (JVB)

## Perfect for

Teams and organisations that want private meetings with colleagues, customers or friends without sending their calls through a third-party service.

## Good to know

- **Media needs a UDP port.** Audio and video do not travel through the HTTPS address. The videobridge needs UDP port 10000 (or the port you choose) reachable from the participants' browsers, and the public IP address it is reached under. In the install settings choose "Videobridge media port" (NodePort, LoadBalancer or HostPort) and set "Public IP address of the videobridge". The default (ClusterIP, no address) is a safe starting point where the page, rooms and chat work, but participants outside the cluster network cannot see or hear each other. Emporium does not create a UDP load balancer on its own.
- **Firewalls that block UDP.** If a participant's network blocks UDP (many company networks do), there is no media. This chart does not include a TURN relay; run one (for example coturn on TCP/TLS 443) next to Jitsi if you need that. Jitsi's own default is to use a public STUN service (`meet-jit-si-turnrelay.jitsi.net`) for address discovery in the browsers.
- **One videobridge.** The chart runs one videobridge, which is plenty for meetings of a few dozen participants; more capacity needs more bridges with their own addresses and is not part of this chart.
- **Who can create and join meetings.** Jitsi has no single sign-on of its own. This chart puts the Emporium login in front: only signed-in Emporium users can open the page, create a room and join. The first person in a room is its moderator. To let people outside Emporium join, set the access of the app to "public" at install; then anybody who knows the address can also start rooms, so keep the lobby switched on and use room passwords. There is no setting that lets guests join but not create rooms.
- **No data to back up.** Meetings are not recorded or stored; the internal passwords are generated at install.
- Recording, live streaming and dial-in need extra services (Jibri, Jigasi) and are not included.
- Icon: the official Jitsi logo (jitsi-meet `images/favicon.svg`, Apache-2.0).
- The images need privilege escalation with a few capabilities (CHOWN, DAC_OVERRIDE, FOWNER, SETUID, SETGID) for their s6-overlay init; the services run as uid 1000.
