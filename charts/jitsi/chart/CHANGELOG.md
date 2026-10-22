# 0.1.0

- New chart: Jitsi Meet (docker-jitsi-meet release stable-11248, official images `ghcr.io/jitsi/{web,prosody,jicofo,jvb}`), requires Emporium v0.5.0.
- Web, Prosody (XMPP) and Jicofo in one pod, the videobridge in its own pod. No database, no persistent data.
- Emporium login in front (access `authenticated`); set the access to `public` at install to let guests join.
- Videobridge media port is an install input (ClusterIP default, NodePort, LoadBalancer, HostPort) together with the public IP address (`JVB_ADVERTISE_IPS`); no UDP load balancer is created by default.
- Internal component passwords are generated at install and delivered by Secret reference.
- NetworkPolicies: Prosody (5222) only from this release's videobridge, the web port only from the Emporium login proxy and the gateway, the videobridge HTTP port only from this release (UDP media from anywhere). Prosody's HTTP port is not exposed.
- The web port accepts only this release's glass pod (name and instance label), not every glass pod in the namespace.
- Documented: TURN needs chart changes, two-party calls may work peer-to-peer without a reachable videobridge, Prosody account passwords briefly appear in startup arguments (upstream).
- The Jitsi images need privilege escalation with CHOWN, DAC_OVERRIDE, FOWNER, SETUID and SETGID (s6-overlay init); they run as uid 1000.
- Tested on Emporium 0.5.0-rc.12 (2026-10-22): install, sign-in through Emporium, room creation and join, XMPP over websocket, uninstall without leftovers. Media over UDP was not tested.
