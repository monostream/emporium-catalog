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

{{/* Settings shared by the Deployment and the administrator Job. */}}
{{- define "vikunja.env" -}}
- name: VIKUNJA_SERVICE_INTERFACE
  value: {{ printf ":%v" .Values.service.port | quote }}
- name: VIKUNJA_LOG_LEVEL
  value: {{ .Values.config.logLevel | quote }}
- name: VIKUNJA_LOG_PATH
  value: /tmp/logs
- name: VIKUNJA_SERVICE_ENABLEREGISTRATION
  value: {{ .Values.config.enableRegistration | quote }}
- name: VIKUNJA_AUTH_LOCAL_ENABLED
  value: {{ .Values.config.localAuth | quote }}
{{- with .Values.config.publicUrl }}
- name: VIKUNJA_SERVICE_PUBLICURL
  value: {{ . | quote }}
{{- end }}
- name: VIKUNJA_FILES_BASEPATH
  value: /app/vikunja/files
- name: VIKUNJA_DATABASE_TYPE
  value: postgres
- name: VIKUNJA_DATABASE_HOST
  value: {{ printf "%s:%v" .Values.database.host .Values.database.port | quote }}
- name: VIKUNJA_DATABASE_DATABASE
  value: {{ .Values.database.name | quote }}
- name: VIKUNJA_DATABASE_SSLMODE
  value: {{ .Values.database.sslMode | quote }}
{{- with .Values.database.existingSecret }}
- name: VIKUNJA_DATABASE_USER
  valueFrom:
    secretKeyRef:
      name: {{ . }}
      key: {{ $.Values.database.userKey }}
- name: VIKUNJA_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ . }}
      key: {{ $.Values.database.passwordKey }}
{{- end }}
{{- end }}
