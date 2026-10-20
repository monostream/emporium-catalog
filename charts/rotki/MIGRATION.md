# rotki 0.1.x -> 0.2.0 (Emporium 0.5)

## Removed and renamed inputs

None (the chart had no inputs).

## Database

Not replaced. rotki keeps its encrypted per-user SQLite databases under `/data`.

## Data volumes

- `data` (storage integration, default 10Gi, grow-only), mounted at `/data`. The chart used to
  create `data-<release>` itself; that claim is still created when the chart is installed without
  Emporium. 0.1.x never mounted the claim (see below), so existing installs have no data on it:
  export from the rotki UI before migrating.
- `data-<release>` was Helm-managed without a keep annotation; with the `data` integration the chart
  stops rendering it, and both the upgrade and the uninstall of the 0.4 release delete it (a live
  `kubectl annotate` does not protect the uninstall, which reads the stored manifest). It holds no
  rotki data (0.1.x never mounted it), so letting it go is the documented path. Export from the
  rotki UI and import after the reinstall. If you want the claim kept anyway, the old chart passes
  `persistence.annotations` through:

  ```bash
  helm -n <ns> upgrade <release> <catalog-repo>/rotki --version 0.1.26 --reuse-values \
    --set-string 'persistence.annotations.helm\.sh/resource-policy=keep'
  ```

## Hostnames

No extra hosts.

## TLS secret

`<release>-tls` became the integration's `TLSSecretName` (zone dependent).

## Secrets

None.

## Behaviour changes

- Fixed: `/data` is always mounted (0.1.x rendered the mount only when extra `volumeMounts` were
  set, so data was lost on every pod restart).
- No `kubernetes.io/tls-acme` annotation from the chart.
