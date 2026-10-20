# integration-test 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None (the chart had no inputs).

## Database

None.

## Hostnames

- `second.<host>` and `third.<host>` became `<subdomain>-second.<zone>` and
  `<subdomain>-third.<zone>` (extra hosts `second`, `third` of the `ingress` integration), so the
  zone's wildcard certificate covers them.
- One Ingress `<release>` carries all three hosts; `<release>-second` and `<release>-third` are gone.

## TLS secret

`<release>-tls` (and `second-<release>-tls`, `third-<release>-tls`) became the integration's
`TLSSecretName` (zone dependent). The hard-coded `cert-manager.io/cluster-issuer: letsencrypt-staging`
is gone; in perHost zones the issuer comes with the `Annotations` output.

## Secrets

None.

## Behaviour changes

- Ingress integration named `ingress` (the e2e suite in `emporium/test` requires it).
- `image.tag` stays a plain value, so raw overrides such as `{image: {tag: e2e-never-pulls}}` (the
  reception restart test) keep working.
- Stateless; nothing to keep before uninstalling a 0.4 install.
