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

{{/* Database connection variables from the secret written by the postgres integration. */}}
{{- define "chart.dbEnv" -}}
- name: DB_DRIVER
  value: postgres
{{- range $env, $key := dict "DB_USERNAME" .Values.database.keys.username "DB_PASSWORD" .Values.database.keys.password "DB_HOSTNAME" .Values.database.keys.hostname "DB_PORT" .Values.database.keys.port "DB_NAME" .Values.database.keys.name }}
- name: {{ $env }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.database.existingSecret }}
      key: {{ $key }}
{{- end }}
{{- end }}

{{/* libpq TLS settings; PHP-FPM only forwards them because of the php-fpm env file in the ConfigMap. */}}
{{- define "chart.dbTLSEnv" -}}
{{- if .Values.database.caSecret }}
- name: PGSSLMODE
  value: {{ .Values.database.sslMode | quote }}
- name: PGSSLROOTCERT
  value: /etc/kanboard/postgres/ca.crt
{{- else }}
- name: PGSSLMODE
  value: require
{{- end }}
{{- end }}
