# Home Assistant

Home Assistant Core is open-source home automation that puts local control and privacy first: dashboards, automations, scenes and thousands of integrations for lights, sensors, media players, energy meters and more. This chart runs the official container image (`ghcr.io/home-assistant/home-assistant`, Apache-2.0).

This is Home Assistant **Core in a container**: there is no Supervisor, so no add-ons and no add-on store. Everything else (integrations, HACS, automations, dashboards, backups, the companion apps) works.

## What you get

- One pod with the configuration on a persistent volume (`/config`), SQLite history by default.
- An owner account created at install (user name and generated password, see "Sign in").
- Home Assistant behind the Emporium login, with the API and the companion-app login paths open.

## Sign in

Open the app from Emporium (you sign in to Emporium first), then sign in to Home Assistant with the owner account. The user name is the one you chose at install (default `admin`); the password is in the app's Secret:

```
kubectl -n <namespace> get secret <release>-emporium-secrets -o jsonpath='{.data.AdminPassword}' | base64 -d
```

Home Assistant's onboarding page normally lets whoever opens it first claim the installation. Here a sidecar container creates the owner through the onboarding API as soon as Home Assistant answers, so nobody else can. After you sign in, Home Assistant asks for the remaining onboarding steps (location, units, analytics); the owner can change them any time.

## Good to know

**Single sign-on.** Home Assistant Core has no OpenID Connect login. The chart keeps the Emporium login in front and uses Home Assistant's own accounts behind it. Other household members get their own accounts under Settings > People.

**Paths that skip the Emporium login.** `/api/*` (REST API, webhooks, `/api/websocket`) and `/auth/*` (login flow and tokens) skip the Emporium login because Home Assistant authenticates them itself (long-lived access tokens, webhook ids, its own login). So do the static files of the login page. Webhooks, automations calling the API, integrations with OAuth callbacks (`/auth/external/callback`) and the companion apps' API calls work without an Emporium session.

**Companion apps.** The mobile apps load the full Home Assistant frontend in a web view, which cannot sign in to Emporium. To use them, set the app's access to **public** in Emporium when you install or later: Home Assistant's own login (username and password, with optional multi-factor authentication and its IP ban after failed logins) then protects the whole host. With the default (Emporium login in front) use a browser for the dashboards; webhooks and API calls keep working.

**Reverse proxy.** Home Assistant answers `400 Bad Request` to requests that come through a proxy it does not trust. Since 2026.10 Home Assistant keeps its HTTP server settings in `/config/.storage/http` and no longer reads the `http:` YAML key after a one-time migration (the migrated YAML is an unconfirmed trial that Home Assistant reverts after five minutes, which would drop the proxy settings). The chart therefore writes `use_x_forwarded_for: true` and `trusted_proxies` into that file as the stable configuration before every start, keeping the other stored settings. The default trusts the private ranges (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `fd00::/8`), which contain every common Kubernetes pod network; narrow it in the install form to your pod CIDR if you want. Change the trusted proxies in Emporium, not in Home Assistant's HTTP settings: the chart value is applied again at every start.

**Discovery does not work.** There is no `hostNetwork`. Automatic discovery of devices (mDNS/zeroconf, SSDP/UPnP, DHCP, Bluetooth, USB dongles such as Zigbee and Z-Wave sticks, and integrations that listen for broadcasts) cannot see your LAN from a pod, and Home Assistant logs warnings for them. Devices must be reachable over IP from the cluster; add integrations by hostname or address (Settings > Devices & services > Add integration > enter the IP). Integrations that need USB or Bluetooth hardware are not supported. Cloud integrations, MQTT brokers, ESPHome devices addressed by IP, Shelly, Hue bridges by IP, weather, calendars, and similar work. Devices that need to reach Home Assistant (webhooks, push) call the public URL.

**History database.** By default the recorder uses SQLite on the configuration volume, which is fine for a household. Turn on the PostgreSQL integration at install to store history in a CloudNativePG database managed by Emporium instead (connection by Secret reference, TLS required; the recorder is configured in `/config/emporium.yaml`, which `configuration.yaml` includes); this cannot be turned off later. Backups: Home Assistant's own backups (Settings > System > Backups) land on the volume.

**Websockets.** The frontend talks to `/api/websocket`. The chart sets no `proxy-body-size` annotation, which breaks websockets on the Emporium gateway. Large uploads (backups) through the browser are therefore limited by the gateway's default.

**Updates.** The image tag follows the Home Assistant release. Home Assistant upgrades its database and `.storage` files in place; take a backup before major upgrades, downgrades are not supported.

## Values

| Key | Meaning |
|---|---|
| `timezone` | Container time zone |
| `http.trustedProxies` | Comma-separated trusted reverse proxies |
| `admin.username`, `admin.name` | Owner account |
| `extraEnv` | Additional environment variables |
| `resources` | CPU and memory |
