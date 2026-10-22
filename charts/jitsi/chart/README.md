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

- **Media needs a UDP port.** Audio and video do not travel through the HTTPS address. The videobridge needs UDP port 10000 (or the port you choose) reachable from the participants' browsers, and the public IP address it is reached under. In the install settings choose "Videobridge media port" (NodePort, LoadBalancer or HostPort) and set "Public IP address of the videobridge". The default (ClusterIP, no address) is a safe starting point where the page, rooms and chat work, but participants outside the cluster network cannot see or hear each other. Emporium does not create a UDP load balancer on its own. Upstream Jitsi switches to direct peer-to-peer media for calls of exactly two participants, which can work without a reachable videobridge; three or more participants always need it.
- **Firewalls that block UDP, TURN.** If a participant's network blocks UDP (many company networks do), there is no media through the videobridge. This chart has no TURN relay and no TURN settings: Prosody does not advertise one to the browsers, so adding a TURN server (for example coturn on TCP/TLS 443) needs changes to this chart (out of scope for 0.5.0). Jitsi's own default is to use a public STUN service (`meet-jit-si-turnrelay.jitsi.net`) for address discovery in the browsers.
- **Network isolation.** NetworkPolicies (on by default; they need a CNI that enforces them, such as Cilium) let only this release's videobridge reach Prosody (XMPP, port 5222), and the web port only the Emporium login proxy of this release and the ingress gateway (namespace `network-system`; add your own ingress namespace under `networkPolicy.ingressFrom`). Without them any workload in the cluster could join conferences without the Emporium login. The videobridge HTTP port is only reachable from this release; its UDP media port from anywhere.
- **One videobridge.** The chart runs one videobridge, which is plenty for meetings of a few dozen participants; more capacity needs more bridges with their own addresses and is not part of this chart.
- **Who can create and join meetings.** Jitsi has no single sign-on of its own. This chart puts the Emporium login in front: only signed-in Emporium users can open the page, create a room and join. The first person in a room is its moderator. To let people outside Emporium join, set the access of the app to "public" at install; then anybody who knows the address can also start rooms, so keep the lobby switched on and use room passwords. There is no setting that lets guests join but not create rooms.
- **No data to back up.** Meetings are not recorded or stored; the internal passwords are generated at install.
- Recording, live streaming and dial-in need extra services (Jibri, Jigasi) and are not included.
- Icon: the official Jitsi logo (jitsi-meet `images/favicon.svg`, Apache-2.0).
- The images need privilege escalation with a few capabilities (CHOWN, DAC_OVERRIDE, FOWNER, SETUID, SETGID) for their s6-overlay init; the services run as uid 1000.
- **Known upstream limitation.** At startup the Prosody image registers its two internal accounts with `prosodyctl register ... <password>`, so those two generated passwords are briefly visible in the process arguments of the pod (pod-local, startup only; the images offer no other way to set them). They are internal credentials, nobody signs in with them.
