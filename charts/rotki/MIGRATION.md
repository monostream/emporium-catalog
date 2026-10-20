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
  stops rendering it and Helm deletes it on the upgrade. It holds no rotki data, but if you want it
  kept anyway, run this **before the upgrade**:

  ```bash
  kubectl -n <ns> annotate pvc data-<release> helm.sh/resource-policy=keep
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
