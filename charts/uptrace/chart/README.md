Uptrace is an OpenTelemetry-based observability platform that helps you monitor, understand, and optimize complex distributed systems. Think of DataDog or NewRelic, but at a fraction of the cost and with a fixed budget.

## Prerequisites

The [Altinity ClickHouse operator](https://github.com/Altinity/clickhouse-operator) must be installed in the cluster: Uptrace stores spans, logs and metrics in a ClickHouse installation that the operator runs. Emporium checks for its CRD before installing.

## Sending data

Point your OpenTelemetry SDKs or collector at `https://<your uptrace host>` (OTLP/HTTP) with the project DSN shown in Uptrace under the project settings.
