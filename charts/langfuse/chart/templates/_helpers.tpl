{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "chart.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "chart.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "chart.webName" -}}{{ include "chart.fullname" . }}-web{{- end }}
{{- define "chart.workerName" -}}{{ include "chart.fullname" . }}-worker{{- end }}
{{- define "chart.clickhouseName" -}}{{ include "chart.fullname" . }}-clickhouse{{- end }}
{{- define "chart.clickhouseClaim" -}}
{{- default (include "chart.clickhouseName" .) .Values.clickhouse.persistence.existingClaim -}}
{{- end }}

{{- define "chart.labelsFor" -}}
{{- include "chart.labels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- define "chart.selectorFor" -}}
{{- include "chart.selectorLabels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/* Secret value as an environment variable. Usage: include "chart.secretEnv" (list "NAME" "secret" "key") */}}
{{- define "chart.secretEnv" -}}
- name: {{ index . 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ index . 1 | quote }}
      key: {{ index . 2 | quote }}
{{- end }}

{{/*
Environment shared by the web and worker containers: PostgreSQL, ClickHouse, Redis, S3, secrets.
The CloudNativePG server certificate is verified against its CA (Prisma: sslmode=require + sslcert).
*/}}
{{- define "chart.commonEnv" -}}
- name: DATABASE_HOST
  value: {{ .Values.database.host | quote }}
- name: DATABASE_PORT
  value: {{ .Values.database.port | quote }}
- name: DATABASE_NAME
  value: {{ .Values.database.name | quote }}
- name: DATABASE_USERNAME
  value: {{ .Values.database.username | quote }}
{{ include "chart.secretEnv" (list "DATABASE_PASSWORD" .Values.database.passwordSecret .Values.database.passwordKey) }}
- name: DATABASE_ARGS
  value: {{ ternary (printf "sslmode=require&sslcert=/etc/db-ca/%s" .Values.database.caKey) "sslmode=require" (not (empty .Values.database.caSecret)) | quote }}
- name: CLICKHOUSE_URL
  value: {{ printf "http://%s:8123" (include "chart.clickhouseName" .) | quote }}
- name: CLICKHOUSE_MIGRATION_URL
  value: {{ printf "clickhouse://%s:9000" (include "chart.clickhouseName" .) | quote }}
- name: CLICKHOUSE_USER
  value: {{ .Values.clickhouse.user | quote }}
{{ include "chart.secretEnv" (list "CLICKHOUSE_PASSWORD" .Values.secrets.existingSecret "CLICKHOUSE_PASSWORD") }}
- name: CLICKHOUSE_CLUSTER_ENABLED
  value: "false"
- name: REDIS_HOST
  value: {{ .Values.redis.host | quote }}
- name: REDIS_PORT
  value: {{ .Values.redis.port | quote }}
{{ include "chart.secretEnv" (list "REDIS_AUTH" .Values.redis.existingSecret .Values.redis.passwordKey) }}
{{- range $p := list "EVENT" "MEDIA" }}
- name: LANGFUSE_S3_{{ $p }}_UPLOAD_BUCKET
  value: {{ $.Values.s3.bucket | quote }}
- name: LANGFUSE_S3_{{ $p }}_UPLOAD_REGION
  value: {{ $.Values.s3.region | quote }}
- name: LANGFUSE_S3_{{ $p }}_UPLOAD_ENDPOINT
  value: {{ $.Values.s3.endpoint | quote }}
- name: LANGFUSE_S3_{{ $p }}_UPLOAD_FORCE_PATH_STYLE
  value: {{ $.Values.s3.forcePathStyle | quote }}
- name: LANGFUSE_S3_{{ $p }}_UPLOAD_PREFIX
  value: {{ ternary "events/" "media/" (eq $p "EVENT") | quote }}
{{ include "chart.secretEnv" (list (printf "LANGFUSE_S3_%s_UPLOAD_ACCESS_KEY_ID" $p) $.Values.s3.existingSecret $.Values.s3.accessKeyKey) }}
{{ include "chart.secretEnv" (list (printf "LANGFUSE_S3_%s_UPLOAD_SECRET_ACCESS_KEY" $p) $.Values.s3.existingSecret $.Values.s3.secretKeyKey) }}
{{- end }}
{{ include "chart.secretEnv" (list "SALT" .Values.secrets.existingSecret "SALT") }}
{{ include "chart.secretEnv" (list "ENCRYPTION_KEY" .Values.secrets.existingSecret "ENCRYPTION_KEY") }}
- name: NEXTAUTH_URL
  value: {{ .Values.config.baseUrl | quote }}
# v4 stores traces in a new events table; "dual" also keeps the legacy tables the v2/v3 SDKs and the
# /api/public/ingestion endpoint write to. Must be the same on web and worker.
- name: LANGFUSE_MIGRATION_V4_WRITE_MODE
  value: {{ .Values.config.writeMode | quote }}
- name: TELEMETRY_ENABLED
  value: "false"
- name: LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES
  value: "false"
{{- end }}

{{- define "chart.dbCaVolume" -}}
- name: db-ca
  secret:
    secretName: {{ .Values.database.caSecret | default "unset" | quote }}
    optional: true
{{- end }}
