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

{{/* Labels of one component: call with (dict "ctx" $ "component" "hub"). */}}
{{- define "chart.componentSelectorLabels" -}}
{{ include "chart.selectorLabels" .ctx }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "chart.componentLabels" -}}
{{ include "chart.labels" .ctx }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/* Secret key reference of a generated key. */}}
{{- define "chart.secretRef" -}}
secretKeyRef:
  name: {{ required "secrets.existingSecret is set by Emporium" .ctx.Values.secrets.existingSecret }}
  key: {{ .key }}
{{- end }}

{{/* Database URL (sslmode=require) as an env var. */}}
{{- define "chart.databaseUrlEnv" -}}
- name: {{ .name | default "DATABASE_URL" }}
  valueFrom:
    secretKeyRef:
      name: {{ required "database.existingSecret is set by Emporium" .ctx.Values.database.existingSecret }}
      key: {{ .ctx.Values.database.urlKey }}
{{- end }}

{{- define "chart.hubImage" -}}
{{ .Values.hub.image.repository }}:{{ .Values.hub.image.tag }}
{{- end }}
{{- define "chart.spicedbImage" -}}
{{ .Values.spicedb.image.repository }}:{{ .Values.spicedb.image.tag }}
{{- end }}
{{- define "chart.appImage" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end }}

{{/* Variables that point Formbricks at SpiceDB. */}}
{{- define "chart.authzedEnv" -}}
- name: AUTHZED_ENABLED
  value: "true"
- name: AUTHZED_ENDPOINT
  value: {{ printf "%s-spicedb:50051" (include "chart.fullname" .) | quote }}
- name: AUTHZED_TOKEN
  valueFrom:
    {{- include "chart.secretRef" (dict "ctx" . "key" "AUTHZED_TOKEN") | nindent 4 }}
- name: AUTHZED_SYSTEM_KEY
  value: {{ .Values.spicedb.systemKey | quote }}
- name: AUTHZED_INSECURE
  value: "true"
- name: AUTHZED_CONSISTENCY
  value: fully_consistent
{{- end }}

{{/*
Node.js (Prisma's pg adapter) treats sslmode=require as verify-full. The CloudNativePG CA is mounted and
trusted so the connection stays encrypted and verified.
*/}}
{{- define "chart.dbCaEnv" -}}
- name: NODE_EXTRA_CA_CERTS
  value: /etc/db-ca/{{ .Values.database.caKey }}
{{- end }}
{{- define "chart.dbCaMount" -}}
- { name: db-ca, mountPath: /etc/db-ca, readOnly: true }
{{- end }}
{{- define "chart.dbCaVolume" -}}
- name: db-ca
  secret:
    secretName: {{ .Values.database.caSecret | default "unset" | quote }}
    optional: true
{{- end }}
