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

{{/* Environment shared by the bootstrap init container and Mealie: database and seeding settings. */}}
{{- define "chart.initEnv" -}}
- name: DEFAULT_GROUP
  value: {{ .Values.config.defaultGroup | quote }}
- name: DEFAULT_HOUSEHOLD
  value: {{ .Values.config.defaultHousehold | quote }}
{{- with .Values.database.existingSecret }}
- name: DB_ENGINE
  value: postgres
- name: POSTGRES_URL_OVERRIDE
  valueFrom:
    secretKeyRef:
      name: {{ . }}
      key: {{ $.Values.database.urlKey }}
{{- end }}
{{- end }}
