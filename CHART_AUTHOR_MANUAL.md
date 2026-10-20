# Emporium Chart Author Manual (v0.5)

Status: v0.5.0, checked against the code in `integration/cutover` (`pkg/chartspec/schema/v1.json`, `pkg/chartlint`, `pkg/integrations`). Anything marked **TODO** is not defined yet; do not rely on it. The field-by-field reference of `emporium.yaml` is the Emporium docs page "emporium.yaml reference", generated from the same schema.

Start from `charts/_template/` (copy `chart/`, rename, replace the TODOs). `emp chart lint charts/<name>/chart` is the gate; it must be green before a PR.

## 1. Package layout

```
charts/<name>/
  deps.json                 # dependency/appVersion updater (omit while prototyping)
  chart/
    Chart.yaml              # metadata + annotations.emporiumVersion
    emporium.yaml           # ALL structured configuration (this manual)
    values.yaml             # base values; must render on its own
    values.emporium.yaml    # optional: thin Go-template wiring that needs logic
    profiles/<name>.yaml    # plain Helm values per sizing profile
    templates/ README.md CHANGELOG.md assets/
```

- `Chart.yaml` annotations: `displayName`, `category`, `licenses`, `icon`, `gallery`, and `emporiumVersion` (semver, must be `>= 0.5.0`; the catalog currently writes `v0.5.0`). `emporiumVersion` lives only in this `Chart.yaml` annotation; it is not a field of `emporium.yaml`.
- Every chart ships a parseable `emporium.yaml`. Without it, or with `emporiumVersion` missing or below 0.5.0, the version is indexed invalid and cannot be installed.
- Gone in 0.5, do not use: the `## @userSupplied` comment DSL, `.Emporium.UserSupplied`, `.Emporium.Integrations.{DNS,OIDC,SMTP,Storage,Postgres}` aliases, the `emporium.build/postgres` annotation, the `oidcRedirectPaths` annotation (now `redirectPaths` on the `ingress` integration), `kubernetes.io/tls-acme` literals.

## 2. How configuration reaches Helm: the layer stack

Emporium composes one values map and hands it to Helm. Lowest to highest precedence:

| # | Layer | Source |
|---|---|---|
| 0 | chart `values.yaml` (and subchart defaults) | Helm |
| 1 | rendered `values.emporium.yaml` | template + context |
| 2 | selected profile | `profiles.<name>.values` file |
| 3 | inputs with `path:` / `ref:` | deep-set |
| 4 | integration outputs with `bind:` | deep-set |
| 5 | per-component overrides (resources, replicas, knob inputs) | deep-set to declared paths |
| 6 | raw user overrides (Advanced editor) | YAML map |

Deep-set uses Helm `--set` path syntax (`a.b[0].c`; escape dots in keys as `\.`; `/` is allowed for annotation keys). Upgrades use reset-values semantics: the stored settings are re-composed, never "last values plus patch".

Protected paths (installOnly inputs and storage, growOnly sizes, replica bounds, `fixed`, `needsRWX`) are checked on the composed effective values, so a profile or raw override cannot bypass them.

### Declare a path, don't template it

Prefer `path:` (inputs) and `bind:` (integration outputs). They never pass through text, so there is no quoting or escaping bug, `helm get values` shows exactly what was applied, and lint can prove the path exists and is consumed (marker test). Use `values.emporium.yaml` only for what needs logic: lists built from outputs, TOML/config blobs, conditionals on optional integrations, concatenated strings.

## 3. `emporium.yaml` reference

```yaml
apiVersion: emporium.build/v1
sections:      [ { id: general, label: General, description: "" } ]   # optional; "general" always exists
inputs:        { <Key>: { ... } }
integrations:  { <name>: { type: ..., required: true, bind: { <Output>: <path> }, ...params } }
components:    { <id>: { ... } }
profiles:      { default: <name>, <name>: { label, description, values: profiles/<name>.yaml, integrations: { <int>: { ...param overrides } } } }
options:       { installTimeout: 10m, requiredCRDs: [ clusters.postgresql.cnpg.io ] }
```

Everything is optional. Maps keep their order (it is the form order). Duplicate keys are an error.

### 3.1 Inputs

Key pattern `^[A-Z][A-Za-z0-9]*$`.

| Field | Meaning |
|---|---|
| `label`, `description` | Form text. |
| `type` | `string` `secret` `integer` `number` `boolean` `enum` `byteSize` `duration` `storageClass` `cpu` `memory` |
| `default`, `required` | Defaults are visible in the form. Required defaults to false. |
| `options` | Values for `enum`. |
| `min`, `max`, `pattern` | Bounds. For `byteSize`/`cpu`/`memory` write quantities (`1Gi`, `500m`). |
| `path` | Helm values path that receives the value. Omit when `values.emporium.yaml` consumes it via `input "Key"`. |
| `section` | Form section id (default `general`). |
| `installOnly` | Immutable after install (volumeClaimTemplate sizes, topology flavours). |
| `growOnly` | May only increase (PVC sizes). |
| `renamedFrom` | List of old keys (any string, including comment-DSL era names); the stored value is carried over on upgrade. A key in `renamedFrom` must not be declared currently. |
| `showIf` | `{ input: <Key>, equals: <value> }`: hidden inputs are reset to their default. |
| `matrix` | Lint renders the chart with this boolean toggled both ways. |

Secret inputs:

- `generate: { length: 32, charset: alnum }` (charset `alnum|hex|base64|printable`) creates the value once at install; it stays stable on every upgrade. Only valid on `type: secret`.
- `ref: { namePath: <path>, keyPath: <path>, key: <fixed key> }` delivers the secret **by reference** (section 6): Emporium sets `namePath` to `<app>-emporium-secrets` and `keyPath` to the key name (default: the input key; `key` fixes a name the chart insists on). `path` and `ref` are mutually exclusive.
- On update a blank secret field means "keep". The form and API never return the value.

Validation order (server and UI identical): defaults and profile, stored and generated secrets, schema and quantity bounds, integration choices, components, compose, protected-path check.

### 3.2 Integrations

Declared under a name the template and `bind` use: `.Emporium.Integrations.<name>.<Output>`. Types: `ingress oidc smtp storage postgres redis objectStorage app`. `required: false` makes the integration optional. For provisioning types (`postgres`, `redis`, `objectStorage`, `storage`) the install form gains an `enabled` switch (default off) and the integration is absent from the template context, so test with `{{ if .Emporium.Integrations.db }}`. Turning it off later is rejected (uninstall with retainData instead). Changing the type of an existing name in a new chart version rejects the update. Multiple integrations of one type are allowed, keyed by name.

`bind: { <Output>: <values path> }` deep-sets outputs without a template. The output name must exist for the type (lint error otherwise). Outputs flagged secret below should be delivered by reference, not bound as plaintext.

| Type | Params (chart) | User chooses at install | Outputs |
|---|---|---|---|
| `ingress` | `hosts` (extra host keys, e.g. `[registry]`), `redirectPaths`, `access.default`, `skipPaths`, `disableGlass` | zone, subdomain, access (public/authenticated/admins), panel toggle, global annotations | `Hostname`, `Hosts` (map: `registry` -> `<sub>-registry.<zone>`), `AllHosts`, `Subdomain`, `Zone`, `TLSSecretName`, `TLSMode`, `IngressClassName`, `Annotations`, `ClientID` |
| `oidc` | `adminScope`, `scopes`, `ingress` (peer name; default: first ingress) | nothing | `ClientID`, `ClientSecret` (secret), `Issuer`, `ConfigurationEndpoint`, `AdminScope`, `SecretName`, `ClientSecretKey` |
| `smtp` | none | which SMTP config (required when `required`) | `Host`, `Port` (int), `Username`, `Password` (secret), `From`, `ReplyTo`, `SecretName`, `PasswordKey` |
| `storage` | `size {default, growOnly}`, `accessModes`, `storageClass.default` | an existing claim, or size and class for a new one | `ClaimName`, `Capacity`, `StorageClass`, `AccessModes` |
| `postgres` | `database, owner, version, extensions, storage, instances, parameters, resources, secretKeys` | storage size (growOnly), instances, resources | `ClusterName, Host, Port, Database, Username, SecretName, UsernameKey, PasswordKey, URIKey, JDBCURIKey, HostKey, PortKey, DatabaseKey, SSLMode, CASecretName, EnvSecretName`, `Password` (secret, last resort) |
| `redis` | `mode: persistent\|cache` (default persistent), `size`, `maxMemory`, `secretKeys` | `size` (growOnly) | `Host`, `Port`, `SecretName`, `PasswordKey`, `URLKey` (key of the `redis://` URL in `SecretName`), `Password` (secret), `URL` (secret) |
| `objectStorage` | `buckets` (at least one), `size`, `secretKeys` | `size` (growOnly) | `Endpoint`, `Region`, `Buckets`, `SecretName`, `AccessKeyKey`, `SecretKeyKey`, `AccessKey` (secret), `SecretKey` (secret), `PathStyle` |
| `app` | `capability` (required), `permission`, `requires` | the producer app (and its export) among the installed apps | `Instance`, `Export`, `Capability`, `Host`, `Service`, `Namespace`, `Ports`, `Facts`, `Permission`, the export's own outputs, and the credential outputs of the export (section 14) |

Notes per type:

- **ingress**: also declares the app's own hostname; `Hostname` is `<subdomain>.<zone>`. Extra hosts are flat names `<sub>-<host>.<zone>` (for example `<app>-registry.<zone>`), never nested subdomains: one wildcard certificate covers one label level (section 8). Apps without an `ingress` integration get no OIDC client and no access setting. Paths needing no login: `skipPaths`, a list of entries that are either a path ending in a single trailing `*` (prefix match, e.g. `/api/*`) or `regex(<Go regexp>)` (the expression must not contain commas). A `*` anywhere else in a path is literal, not a wildcard. Skip paths that together open the whole app (for example `/*`) are rejected unless `access` is `public`. The Plan notice lists the effective skip paths so the installer can see what is open. `IngressClassName` is the class the zone's controller serves: charts must set `ingressClassName` from it (section 8).
- **oidc**: shares the ingress's IdP client when the app has an `ingress`; the redirect URIs come from the ingress's `redirectPaths`. A pre-existing client without an Emporium owner id is reused and never deleted.
- **storage**: PVC sizes are `growOnly`; a claim you declare is created by Emporium and bound by `ClaimName` (`existingClaim` style charts). An existing claim chosen by the user is never owned.
- **postgres**: provisioned as a CloudNativePG cluster named `<release>-<integration>` (the integration named `postgres` keeps `<release>-postgres`; `db` gives `<release>-db`). The CNPG operator is a prerequisite, not part of the chart. Params: `version` (major, e.g. `"17"`), `database`, `owner`, `extensions` (declare every extension the app needs; they are created at database init), `storage` (`{default: 10Gi, growOnly: true}`), `instances`, `parameters` (postgresql.conf), `resources`. `secretKeys: { <ENV_NAME>: <source key> }` copies source keys into the per-app Secret under the names the chart wants. Source keys: `username, user, password, dbname, host, port, uri, jdbc-uri, fqdn-uri, fqdn-jdbc-uri, pgpass`, plus computed `uri-sslmode-require` and `jdbc-uri-nocreds`. `uri` has no query string (no sslmode). Keys are copied verbatim; there is no templated key. Reserved (not available): custom `image`, `sharedPreloadLibraries`, `roles`, `postInitSQL`, `superuser`. Consume with `SecretName`/`UsernameKey`/`PasswordKey` and `existingSecret`/`secretKeyRef`, or `envFrom` on the per-app Secret. `Password` exists only as a last resort (plaintext into the Helm release; lint warns). Apps that tolerate SQLite can declare it `required: false` for an install toggle. TODO: "use an existing cluster" is not defined for 0.5.
- **redis**: Valkey (Redis 7.2 wire-compatible), no operator; `cache` mode has no PVC and evicts (`allkeys-lru`), `persistent` is AOF with `noeviction`. `URLKey` names the key of the `redis://` URL inside `SecretName`; read it with `secretKeyRef` instead of using the `URL` output.
- **objectStorage**: RustFS (S3). `AccessKey` and `SecretKey` are secrets like the redis password: deliver them with `SecretName` plus `AccessKeyKey` / `SecretKeyKey`, not through the plaintext outputs.
- **app**: a connection to another installed app. See section 14.

Providers add their own pods and PVCs to the footprint shown in the preview.

### 3.3 Components (sizing)

Components make a workload editable and countable. Declare them for every workload that matters.

| Field | Meaning |
|---|---|
| `label` | Name in the form. |
| `resources` | Values path of the container resources map. Lint marker-tests it. |
| `replicas` | `{ path, min, max }`, or `{ minPath, maxPath, min, max }` for HPA-managed, or `{ fixed: 1, reason: "SQLite" }`. `fixed` excludes paths; the server rejects changes. |
| `storage` | `{ path, installOnly }` or `{ input: <Key> }`: the component's volume size. |
| `enabled` | Values path (boolean) that lets a profile or the user turn an optional component off. |
| `parent` | Component id of the parent workload. Declares a sidecar: a real sidecar container in the parent's pod, sized with the parent. It has no `match` and no `replicas` of its own. |
| `perNode` | DaemonSet: footprint is multiplied by node count. |
| `integration` | Workload provided by an integration (for example the CNPG cluster), sized through it. |
| `knobs` | Inputs shown next to the component (Puma workers coupled to memory). |
| `needsRWX` | Replicas above 1 require an RWX storage class. |
| `match` | `{ kind, name, matchLabels }` overrides how the component is matched to rendered workloads (default: kind any, name `*<last path segment before .resources>*`). Lint `component-unmatched` fires when nothing matches. |

Without any `components`, Emporium synthesizes `app: { resources: resources, replicas: { path: replicaCount } }` when the chart's values have a top-level `resources` and/or `replicaCount`. For wrapper charts whose single dependency alias is the chart name, the same rule applies one level down (`<alias>.resources`). TODO: the exact synthesis conditions are in the compiler; declare components explicitly when in doubt.

### 3.4 Profiles

`profiles.default` names the preselected profile. Each profile is a plain Helm values file (`values: profiles/<name>.yaml`, relative to the chart root) that may set any key, plus optional per-integration param overrides (`integrations: { db: { instances: 1, resources: {...} } }`). The footprint shown on the profile card is computed by the preview, not declared.

### 3.5 Sections and options

`sections` orders and labels form groups; inputs reference them by `section`. `options.installTimeout` (default 10m) and `options.requiredCRDs` (a preflight: install fails early when a CRD is missing; operators are consumed, never managed) are the only options.

## 4. Template context (`values.emporium.yaml`)

Go `text/template` plus sprig (a sandboxed function set: `env`, `expandenv`, `getHostByName` are removed) and Helm's `toYaml/fromYaml/toJson/...`. The output must be a YAML map; duplicate keys are an error. It cannot see layers 2-6.

```
.Emporium.Name  .Namespace  .Annotations  .Profile  .OwnerID   # OwnerID: producers of app connections only (section 14)
.Emporium.Inputs.<Key>
.Emporium.Integrations.<name>.<Output>        # absent when an optional integration is off
.Emporium.Secrets.Name                        # "<app>-emporium-secrets"
input "Key"        # value as a JSON scalar, always valid YAML: size: {{ input "StorageSize" }}  ->  size: "8Gi"
required "msg" v   # fail rendering when empty
integration "name" # the integration's output map
```

Write `{{ input "X" }}` or `{{ ... | quote }}` / `toYaml` / `toJson` in value positions. A bare `{{ .Emporium.Inputs.X }}` is lint warning `bare-interpolation`.

## 5. What belongs where

| Need | Use |
|---|---|
| Couple several knobs to a size (Puma workers vs memory, JVM heap, `extendedConfiguration`, disable kas/exporter/canary) | **Profile**. Only the chart author knows the coupling. |
| Something the user should decide (admin email, feature switch, retention) | **Input** with `path:`. |
| One more container needs more CPU/memory/replicas | **Component override** (the user does this in the editor; you declare the component). |
| Storage sizes | **Input** (`installOnly`/`growOnly`) or `storage` integration. Never in a profile. |
| Value derived from an integration | `bind:` first, `values.emporium.yaml` if it needs logic. |

Profiles are the base layer; component overrides sit above them and survive a profile switch (shown as "custom", resettable). Keep profiles to resources, replicas and coupled settings.

## 6. Secrets: delivery by reference

All generated, user-supplied and integration-derived secrets live in one Secret per app, `<app>-emporium-secrets`, with stable keys: input keys as declared (or `ref.key`), and provider-derived keys `<type>.<integration>.<key>` (for example `oidc.sso.clientSecret`, `smtp.mail.password`) plus your `secretKeys` names. Deliver them by reference:

- `existingSecret` / `secretKeyRef` / `envFrom` pointing at `<app>-emporium-secrets` (`.Emporium.Secrets.Name`), key names from the outputs (`PasswordKey`, `ClientSecretKey`) or from the input's `ref`.
- Plaintext into values (`path:` on a secret input, `Password`/`ClientSecret`/`SecretKey` outputs in templates or binds) is a last-resort fallback: it lands in the Helm release Secret. Lint warns (`plaintext-secret-in-values`, `plaintext-secret-output`); acknowledge it with a comment only when the upstream chart gives no alternative (porter is the known case).
- A Secret annotated `emporium.build/secrets-managed-by=external` is read, never written (External Secrets compatibility by naming only; no ESO code).
- Never use Helm `lookup` to read or keep a password (preview cannot diff `lookup` charts; use a generated input or a derived secret). Charts that still use `lookup` still render, but get no manifest diff in preview (lint warning `lookup-offline`).
- Secrets created by Helm hooks (`helm.sh/hook` on a Secret) are not part of the release and block namespace cleanup on uninstall. Prefer Emporium-generated secrets via appsecrets (`generate:` inputs or provider `secretKeys`, delivered by reference) over hook-created Secrets.

## 7. Storage rules

- PVC sizes are **growOnly**: never offer a shrink. StatefulSet `volumeClaimTemplates` sizes and topology flavours are **installOnly** (Kubernetes forbids changing them).
- Expose sizes as inputs or via a `storage` integration, never inside profiles.
- Replicas above 1 on a ReadWriteOnce volume are a bug: use `replicas: { fixed: 1, reason: ... }` or `needsRWX: true`.
- Never hard-code a storage class; offer `storageClass` as input or integration choice.

## 8. Ingress, TLS, hostnames

- Charts stay ingress-controller agnostic: plain `Ingress` objects, `pathType: Prefix`, `ingressClassName` set from the ingress output `IngressClassName` (bind it, or read it in `values.emporium.yaml`; never hardcode `nginx`, never use the `kubernetes.io/ingress.class` annotation), no controller snippets. Supported annotation subset: `nginx.ingress.kubernetes.io/proxy-body-size`, `proxy-connect-timeout`, `proxy-read-timeout`, `backend-protocol: HTTPS` (best effort). Dropped silently: `*-snippet`, `affinity`/`session-cookie-*`, `hsts*`, `ssl-protocols`, `proxy-buffering`, `proxy-http-version`, `proxy-send-timeout`, `proxy-redirect-*`. Match app-side limits (upload size) with `proxy-body-size`.
- Use the `Annotations` output verbatim on your Ingress (it carries app name, auth, OIDC redirect paths and, in perHost mode, the zone's cert-manager issuer). Use `TLSSecretName` for `tls[].secretName`. Do not write `kubernetes.io/tls-acme` or `cert-manager.io/cluster-issuer` literals (`tls-hardcoded` warning).
- DNS zones run in one of two TLS modes: `perHost` (one certificate per host via the issuer annotation) or `wildcard` (one `*.<zone>` certificate; secret `emporium-wildcard-<zone>` replicated into app namespaces). A wildcard certificate covers one label, so **hostnames are flat**: `<app>-registry.<zone>`, never `registry.<app>.<zone>`. Declare extra hosts with `hosts: [registry]` and read `Hosts.registry` / `AllHosts`.
- Consume `Hostname`/`Hosts` for every URL the app derives (external URL, redirect, CORS); never assemble a hostname from the app name.
- **Default subdomain.** When the installer sets no `subdomain`, the host label is the release name for the chart's first `ingress` integration (declaration order) and `<release>-<integration>` for every other one. Two ingress integrations of one chart therefore never share a host by default. A label longer than 63 characters is shortened. If you set a `subdomain` choice or profile override so that two ingress integrations of the same app end up with the same host, the preview rejects it on the `subdomain` field ("host ... is already used by ingress integration ... of this app"). Declare distinct `hosts` keys instead of two ingress integrations when the second host serves the same app.
- **Ingress class.** `IngressClassName` is the value of the Emporium chart setting `providers.ingress.ingressClassName`; when that is empty it is empty too and the Ingress uses the cluster's default IngressClass. Always bind or read it; an empty value is valid, so do not guard it with `required`. The admin sets it at Emporium install time (see the Emporium chart README), not per app.

## 9. No Bitnami subcharts where a provider exists

Where Emporium has a provider (`postgres`, `redis`, `objectStorage`) do not ship a Bitnami subchart as the default; disable it (`postgresql.enabled: false`) and consume the integration. Set the subchart's `existingSecret` style values to the integration's outputs. MySQL and ClickHouse have no provider: keep a non-Bitnami or legacy-pinned image that installs. Documented exceptions need a note in the chart README and in `MIGRATION.md`. The one exception today is **supabase**: it keeps its own `supabase/postgres` database because it needs a custom image, about 50 extensions, `shared_preload_libraries` and several service roles created as superuser at init, none of which the `postgres` provider offers. It declares no `postgres` integration and gives the database volume a `storage` integration, so the volume is still sized and kept by Emporium. Do not copy this pattern for an app that only needs ordinary extensions: declare them in `extensions` instead.

## 10. Lint

`emp chart lint charts/<name>/chart` renders every profile (and `matrix` toggles) with a fake context and fails on any error. `emp chart lint --dump-dir <dir>` writes the rendered manifests of every profile to `<dir>` for inspection. Rule names below are the codes of `pkg/chartlint`; `emp chart lint` prints the code with every finding.

Errors: `emporium.yaml` fails the v1 JSON Schema; unknown integration type; `schema-remote-ref` (a JSON Schema `$ref`/`$schema` pointing at a non-standard remote id; the standard meta-schema ids are accepted); an unresolved `parent:` (a sidecar component needs an existing parent, no own `match` or `replicas`); `bind` output not valid for the type; component, parent, knob, integration or `showIf` reference unresolved; `profiles.default` missing; a declared `path` does not exist in the chart's values (unless `values.emporium.yaml` creates it); undeclared integration or input used in the template (`integration-undeclared`, `input-undeclared`); legacy context (`legacy-context`); duplicate YAML keys in the rendered values; `helm template` render failure; `emporiumVersion` missing or below 0.5.0; marker test failure (a sentinel set at a declared `resources`, replica, storage or input path does not appear in the manifests); profile violating `fixed`/`max` replica bounds, or `needsRWX` component above 1 replica.

App connection rules (section 14): `app-same-as-invalid`, `export-grants-path-missing`, `export-grants-path-not-list`, `export-fact-type`, `export-output-reserved`, `export-permission-unknown`, `export-render-failed`, `export-service-not-rendered`, `export-port-not-on-service`, `exported-secret-not-rendered`, `grants-path-override` and `connection-fixture-invalid` are errors; `connection-fixture-missing`, `connection-fixture-incomplete`, `export-networkpolicy-missing` and `exported-role-not-scoped` are warnings.

Disabled subcharts: lint renders with the chart's defaults and the profiles, and runs Helm's own dependency processing (conditions, tags, aliases) for each render. Findings that look inside subcharts, namely `lookup` calls and remote schema references, are reported only for subcharts that at least one lint render enabled. A subchart you disable by default (`postgresql.enabled: false`) and no profile enables is not checked for them. Its values paths are still valid for `path:` and `bind:`, because disabled subcharts keep their defaults in the path check. Remote `$ref` in any bundled `values.schema.json`, enabled or not, is stripped before rendering (lint warning `lint-skipped`), so those values are not validated against the schema.

Warnings: `lookup-offline` (the chart calls `lookup`; it still renders, preview has no manifest diff); `bare-interpolation`; `plaintext-secret-in-values`; `plaintext-secret-output`; `tls-hardcoded`; `component-unmatched`; a workload container with no requests in a profile (footprint report).

## 11. Worked example: simple app (vaultwarden)

`emporium.yaml`:

```yaml
apiVersion: emporium.build/v1
integrations:
  web:
    type: ingress
    access: { default: authenticated }
    skipPaths: ["/api/*", "/#/*"]
    bind:
      Hostname: ingress.hosts[0].host
      Annotations: ingress.annotations
      TLSSecretName: ingress.tls[0].secretName
  data:
    type: storage
    size: { default: 10Gi, growOnly: true }
    bind: { ClaimName: storage.data.existingClaim }
  mail:
    type: smtp
    required: false
inputs:
  SignupsAllowed:
    label: Allow signups
    type: boolean
    default: false
    path: app.signupsAllowed
components:
  app:
    label: Vaultwarden
    resources: resources
    replicas: { fixed: 1, reason: "SQLite on a ReadWriteOnce volume" }
profiles:
  default: small
  small: { label: Small, description: "Up to a few dozen users", values: profiles/small.yaml }
```

A single-workload chart gets exactly one profile, `small`, like `charts/_template`.

`values.emporium.yaml` keeps only what binds cannot express (a derived URL, a list, the optional SMTP block):

```yaml
app:
  domain: {{ printf "https://%s" .Emporium.Integrations.web.Hostname | quote }}
  {{- with .Emporium.Integrations.mail }}
  smtp:
    host: {{ .Host | quote }}
    port: {{ .Port }}
    from: {{ .From | quote }}
    existingSecret: {{ $.Emporium.Secrets.Name | quote }}   # deliver the password by reference when the chart supports it
    passwordKey: {{ .PasswordKey | quote }}
  {{- end }}
ingress:
  hosts:
    - paths: [ { path: /, pathType: Prefix } ]
  tls:
    - hosts: {{ .Emporium.Integrations.web.AllHosts | toJson }}
```

(The chart's templates must read `app.smtp.existingSecret`/`passwordKey`; if upstream only accepts a plaintext password, bind `Password` and accept the `plaintext-secret-output` warning.)

## 12. Worked example: wrapper chart (gitlab, abridged)

Wrapper charts depend on an upstream chart under an alias; every `path` is written from the wrapper's root (`gitlab.gitlab.webservice...`).

```yaml
apiVersion: emporium.build/v1
integrations:
  web:
    type: ingress
    access: { default: authenticated }
    redirectPaths: [/users/auth/openid_connect/callback]
    hosts: [registry]                         # -> <app>-registry.<zone>
  sso:  { type: oidc, adminScope: true }
  mail: { type: smtp, required: false }
  db:
    type: postgres
    version: "17"
    database: gitlabhq_production
    extensions: [pg_trgm, btree_gist, amcheck, plpgsql]
    storage: { default: 10Gi, growOnly: true }
inputs:
  GitalyStorage:
    label: Git repository storage
    type: byteSize
    default: 50Gi
    installOnly: true                         # StatefulSet volumeClaimTemplate
    path: gitlab.gitlab.gitaly.persistence.size
  PumaWorkers:
    label: Puma workers per web pod
    description: Memory per web pod is about 1.25 GB x workers.
    type: integer
    min: 1
    max: 8
    path: gitlab.gitlab.webservice.workerProcesses
components:
  webservice:
    label: Web (Puma)
    resources: gitlab.gitlab.webservice.resources
    replicas: { minPath: gitlab.gitlab.webservice.minReplicas, maxPath: gitlab.gitlab.webservice.maxReplicas, min: 1, max: 10 }
    knobs: [PumaWorkers]
  workhorse: { parent: webservice, resources: gitlab.gitlab.webservice.workhorse.resources }
  gitaly:
    label: Git storage
    resources: gitlab.gitlab.gitaly.resources
    replicas: { fixed: 1 }
    storage: { input: GitalyStorage }
  db: { label: PostgreSQL, integration: db }
profiles:
  default: small
  small:
    label: Small
    description: "Evaluation, up to ~25 users"
    values: profiles/small.yaml               # sets workerProcesses, replicas, disables kas/exporter
    integrations: { db: { instances: 1, resources: { requests: { cpu: 250m, memory: 512Mi }, limits: { memory: 1Gi } } } }
  medium:
    label: Medium
    description: "Team, ~100-500 users"
    values: profiles/medium.yaml
    integrations: { db: { instances: 1, resources: { requests: { cpu: "1", memory: 2Gi }, limits: { memory: 4Gi } } } }
```

`values.emporium.yaml` shrinks to the database block, wired by reference, plus OIDC and SMTP blocks (shape depends on the upstream chart):

```yaml
gitlab:
  global:
    psql:
      host: {{ .Emporium.Integrations.db.Host | quote }}
      port: {{ .Emporium.Integrations.db.Port }}
      database: {{ .Emporium.Integrations.db.Database | quote }}
      username: {{ .Emporium.Integrations.db.Username | quote }}
      password:
        secret: {{ .Emporium.Integrations.db.SecretName | quote }}
        key: {{ .Emporium.Integrations.db.PasswordKey | quote }}
  postgresql:
    install: false                            # no Bitnami subchart where a provider exists
```

Wrapper-chart checklist: disable the bundled subchart DB, point every credential at `SecretName` + key, declare the registry host through `hosts`, keep storage sizes out of profiles, and write a `MIGRATION.md` listing removed/renamed inputs, whether the DB needs migrating and any TLS secret change.

## 13. Before opening a PR

1. `emp chart lint charts/<name>/chart` is green for every profile.
2. Version bumped in `Chart.yaml`, `CHANGELOG.md` entry added (the catalog repository rejects duplicate versions).
3. README is short and product-oriented (features, perfect-for), not technical.
4. Security context matches the container user (`runAsNonRoot`, drop ALL capabilities, `fsGroup` for volumes).
5. No hardcoded ingress class (use `IngressClassName`), tls-acme or snippet annotations; no plaintext secrets unless unavoidable and acknowledged.

TODO (not defined): `emp chart lint` exit codes; schema for `README`/gallery assets; the `migrations:` list for future chart upgrades (not part of v1); `lookup: cluster` preview support.

Archiving a chart: move `charts/<name>/` to `archive/charts/<name>/`. Do not delete it. `removed-charts.txt` is separate: it only lists chart names whose published versions are purged from the Helm repository.

## 14. App connections

An app can offer a service to other installed apps (a producer) or use one (a consumer). Emporium has no list of capabilities. A capability id such as `bitcoind-rpc/v1` is an opaque string that chart authors agree on. Emporium checks structure at lint time and the actual export at preview and install time. The user guide and the full reference are in the Emporium docs, page "App connections". Working examples: `apps/bitcoin-core` (producer, `rpcauth`), `apps/lnd` (producer with `exported` credentials and consumer), `apps/lnbits` and `apps/mempool` (consumers) in the `emporium-bitcoin` repository.

### Producer: `exports`

```yaml
exports:
  rpc:                                   # export name ^[a-z][a-z0-9-]*$
    capability: bitcoind-rpc/v1
    service: "{{ .Emporium.Name }}"      # Service the chart renders; host is <service>.<namespace>.svc
    ports: { rpc: 8332 }
    facts:                               # typed facts consumers can require
      Network: { type: string, value: "{{ .Emporium.Inputs.Network }}", immutable: true }
      TxIndex: { type: boolean, value: "{{ .Emporium.Inputs.TxIndex }}" }
    outputs:                             # extra string outputs for consumers
      RPCURL: "http://{{ .Export.Host }}:{{ .Export.Ports.rpc }}"
    credentials: { kind: rpcauth }       # none | rpcauth | exported
    grantsPath: bitcoind.grants          # list in values.yaml, default []
    grantRestarts: true                  # pods restart when grants change
```

- Required: `capability`, `service`, `ports`, `grantsPath`. The `grantsPath` list must exist in `values.yaml` with default `[]`.
- Emporium writes one entry per connected consumer into `grantsPath` on every render, as the last values layer. Do not set it in a profile or override it; lint fails with `grants-path-override`.
- The chart must render the NetworkPolicy from that list: admit its own namespace plus the `namespace` of every entry. Emporium creates no object in the producer namespace. Lint warns with `export-networkpolicy-missing`.
- `credentials.kind: rpcauth`: each entry has `user` and `hash`; the chart writes the `rpcauth=<user>:<hash>` lines. `credentials.kind: exported`: the chart renders a Secret named by `secret` **without `data`**, annotated `emporium.build/export-owner-id: {{ .Emporium.OwnerID | quote }}`, plus a Role limited by `resourceNames` to that Secret for the sidecar that fills it. Emporium copies the selected `keys` into each consumer's own Secret.
- Facts and outputs are rendered with the values-template context plus `.Export`. Prefer `.Emporium.Inputs.X` in facts. `immutable: true` pins the fact for every consumer: it cannot change while a consumer is connected.
- A producer update that removes or changes something a consumer depends on is rejected, and a producer cannot be uninstalled while it has consumers.

### Consumer: `type: app`

```yaml
integrations:
  bitcoind:
    type: app
    capability: bitcoind-rpc/v1
    requires: { TxIndex: true, Pruned: false }
  lightning:
    type: app
    capability: lnd/v1
    permission: readonly                 # must be offered by the export
    required: false
    requires:
      Network: { sameAs: bitcoind }      # same fact as an EARLIER app integration of this chart
    bind: { Host: node.rpcHost }
```

- `requires` compares a fact to a scalar, or with `sameAs: <name>` to the same fact of an earlier `type: app` integration of the same chart. A missing fact fails the check. Version floors are boolean facts (equality only).
- The installer picks the producer app (`instance`) and, if it has several exports of the capability, the `export`. A connection cannot be switched later. An optional connection can be turned off and on again with another producer.
- Outputs in the template: `.Emporium.Integrations.<name>.Host`, `Ports`, `Facts`, the export's own outputs and, by credential kind, `Username` / `SecretName` / `PasswordKey` (`rpcauth`) or `<Output>Key` (`exported`). Read the key names with `secretKeyRef`. Static references to outputs are recorded; preview rejects a producer that lacks one (`app-output-missing`).

### Fixtures and lint

A consumer chart ships `ci/connections.yaml`: integration name -> the outputs a producer would provide (`Host`, `Ports`, `Facts`, `SecretName`, `<Output>Key`, ...). Lint renders the chart with it. Without the file the render checks for that chart are skipped (warning `connection-fixture-missing`); an output the chart uses but the file lacks gives `connection-fixture-incomplete`. A producer needs no fixture; lint uses one synthetic grant per export.

### Rules of thumb

- Generated wallet material, such as the lnd seed, lives in the app's own Secret. Uninstalling the app deletes it, so tell users to back it up (docs page "App connections").
- Do not use a `type: app` integration to reach something outside the cluster. Offer a plain input for that.
