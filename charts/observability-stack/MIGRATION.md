# observability-stack 0.0.x -> 0.1.0 (Emporium 0.5)

## Removed and renamed inputs

| Old key | New key | Note |
|---|---|---|
| `PrometheusEnabled` | `PrometheusEnabled` | Unchanged (default `false`). |
| `PrometheusRetention` | `PrometheusRetention` | Now validated (`10d`, `120h`, ...). |
| `PrometheusRetentionSize` | `PrometheusRetentionSize` | Now validated (`18GB`, `500MiB`, empty). |
| `PrometheusStorageSize` | `PrometheusStorageSize` | installOnly. |
| `LokiStorageSize` | `LokiStorageSize` | installOnly. |
| `TempoStorageSize` | `TempoStorageSize` | installOnly. |
| `TempoRetention` | `TempoRetention` | Go duration only (`168h`, not `7d`). A stored `7d` fails validation: set `168h` during the migration. It had no effect before (dead key). |

New inputs: `AdminUser` (default `admin`), `AdminPassword` (generated).

## Database

None. Loki, Tempo and Prometheus keep their data on their StatefulSet volumes.

## Volumes

All data volumes come from StatefulSet volume templates (`storage-<release>-loki-0`,
`storage-<release>-tempo-0`, `prometheus-<release>-prometheus-db-...`); Helm does not delete them
on uninstall, and a reinstall under the same release name in the same namespace reuses them. Moving
to a new namespace (`emp-<app>`) starts with empty logs, traces and metrics.

## Hostnames

No extra hosts.

## TLS secret

`grafana-<release>-tls` became the integration's `TLSSecretName` (zone dependent:
`<release>-tls` in perHost mode, `emporium-wildcard-<zone>` in wildcard mode).

## Secrets

- Grafana admin user and password: `<app>-emporium-secrets` (`admin-user`, `admin-password`).
  Grafana stores its users in a SQLite file inside the pod (no volume), so the new password applies
  on the first start.
- No plaintext secrets in values. Loki (minio, disabled) and the Grafana image renderer/PVC
  helpers still contain Helm `lookup` calls: no manifest diff in preview.

## Cluster-scoped objects (one install per cluster)

- Always: ClusterRoles/Bindings for Alloy (reads pod logs on every node through a DaemonSet with
  `/var/log` host mounts) and the Grafana dashboard sidecar (watches ConfigMaps in all namespaces).
  Their names are release-based, so two installs do not collide by name, but both would collect
  the same logs.
- With `PrometheusEnabled`: kube-prometheus-stack's `monitoring.coreos.com` CRDs (installed from
  the chart's `crds/` when missing, never upgraded or removed by Helm), a prometheus-operator
  watching all namespaces, admission webhooks (cluster-scoped Mutating/ValidatingWebhookConfiguration),
  node-exporter on every node (host network/PID), kube-state-metrics and control-plane
  ServiceMonitors. Do not enable it on a cluster that already runs a prometheus-operator: two
  operators reconcile the same Prometheus/ServiceMonitor objects. `requiredCRDs` does not apply: the
  chart ships the CRDs it needs.

## Behaviour changes

- Tempo retention takes effect (it was ignored and stayed at 24h).
- Loki canary and Helm test pods are gone.
- The chart no longer writes `emporium.build/auth-*` or `kubernetes.io/tls-acme` annotations.
