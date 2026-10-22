# headscale 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None removed. New generated input `CookieSecret` (Headplane session secret, 32 characters).

## Database

Not replaced. headscale keeps SQLite (`/data/db.sqlite`) on the data volume.

## Data volumes

- `data` (storage integration, default 1Gi, grow-only), mounted at `/data`: SQLite database,
  noise private key, DERP key. Losing it means every node has to re-register: keep it on uninstall.
  Existing installs are moved with the installed-app blueprint
  (`docs/blueprints/migrate-installed-app-to-v0.5.md`) by choosing the old claim as existing claim.
- No Helm-managed claim to protect: under Emporium 0.4 the claim came from the old storage
  integration (`existingClaim` was always set), so the chart never rendered its own PVC and the
  upgrade does not delete anything.

## Hostnames

No extra hosts. The ingress runs without glass (`disableGlass: true`): Tailscale clients reach
headscale directly; headscale (`/oidc/callback`) and Headplane (`/admin/oidc/callback`) use the
`sso` OIDC client of their own.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

- OIDC client secret: `<app>-emporium-secrets`, key `oidc.sso.clientSecret`, given to headscale as
  `HEADSCALE_OIDC_CLIENT_SECRET` (was plaintext in the ConfigMap) and to Headplane by `secretKeyRef`.
- Headplane cookie secret: `<app>-emporium-secrets`, key `COOKIE_SECRET` (was `randAlphaNum` + `lookup`
  in `<release>-root-api-key`, 36 characters).
- Root API key: still created by the post-install job in `<release>-root-api-key`; the chart renders
  the Secret without data so upgrades keep the key without `lookup`. The Secret is no longer kept on
  uninstall (`helm.sh/resource-policy: keep` removed); a reinstall creates a new API key.

## Behaviour changes

- Redirect path `admin/oidc/callback` fixed to `/admin/oidc/callback`.
- OIDC scope `custom` dropped (not a Logto scope).
- Post-install job image `bitnami/kubectl` (no longer pullable) -> `alpine/k8s:1.31.4`; the job no
  longer prints the API key to its log.
- No `emporium.build/auth-skip-paths`, `emporium.build/disable-glass` or `kubernetes.io/tls-acme`
  annotations from the chart.

## Headplane configuration (0.2.1)

Headplane 0.7.1 is configured through `/etc/headplane/config.yaml` and `HEADPLANE_*` overrides
(the old flat variables were ignored by it). Headplane's own state (users, roles) is kept on the data
volume under `headplane/`; the first user who signs in through OIDC becomes the Headplane owner.
Sign-in: OIDC button, or the API key login (break-glass, works when the identity provider is down):

    kubectl exec deploy/<release> -c headscale -- headscale apikeys create --expiration 24h

## Who can register nodes

The ingress runs without glass (Tailscale clients cannot pass a forward-auth login), so the Emporium
access policy does not gate headscale or Headplane; the identity provider does. By default every user
of the identity provider can register nodes (`oidc.allowedDomains` / `oidc.allowedUsers` restrict this).
Restricting to Emporium admins is not possible: headscale only reads a `groups` claim for
`allowed_groups`, and Logto issues the Emporium roles in `roles`.
