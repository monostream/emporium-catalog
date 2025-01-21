{{/*
Expand the name of the chart.
*/}}
{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
helm.sh/chart: {{ include "chart.chart" . }}
{{ include "chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Reuse existing secret value or use a provided default.
*/}}
{{- define "chart.secretValue" -}}
{{- $secretName := .secretName -}}
{{- $key := .key -}}
{{- $defaultValue := .defaultValue -}}
{{- $currentValue := (lookup "v1" "Secret" .Release.Namespace $secretName).data -}}
{{- if and $currentValue (get $currentValue $key) -}}
  {{- get $currentValue $key -}}
{{- else -}}
  {{- $defaultValue | b64enc -}}
{{- end -}}
{{- end -}}

{{/*
Define a helper to get the PostgreSQL service host
*/}}
{{- define "chart.postgresqlServiceHost" -}}
{{- if .Values.postgresql.fullnameOverride }}
{{- .Values.postgresql.fullnameOverride }}
{{- else }}
{{ include "chart.fullname" . }}-postgresql
{{- end }}
{{- end -}}

{{/*
Return the environment variables DB_PASSWORD and DB_URI
*/}}
{{- define "chart.database.env" -}}
- name: DB_PASSWORD
  {{- if .Values.postgresql.auth.existingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgresql.auth.existingSecret }}
      key: postgres-password
  {{- else }}
  value: {{ .Values.postgresql.auth.password | quote }}
  {{- end }}
- name: DATABASE_URL
  value: postgresql://{{ .Values.postgresql.auth.username }}:$(DB_PASSWORD)@{{ .chart.postgresqlServiceHost }}:{{ .Values.postgresql.auth.port }}/{{ .Values.postgresql.auth.database }}
{{- end -}}

{{/*
Return the environment variables for S3
*/}}
{{- define "chart.s3.env" -}}
- name: S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.minio.auth.existingSecret }}
      key: root-user
- name: S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.minio.auth.existingSecret }}
      key: root-password
- name: S3_ENDPOINT
  value: "https://{{ .Values.minio.apiIngress.hostname }}"
- name: S3_BUCKET
  value: "{{ .Values.s3.bucket }}"
- name: S3_PUBLIC_DOMAIN
  value: "https://{{ .Values.minio.apiIngress.hostname }}"
- name: S3_ENABLE_PATH_STYLE
  value: "1"
{{- end -}}

{{/*
Return the environment variables for app
*/}}
{{- define "chart.app.env" -}}
- name: APP_URL
  value: "{{ .Values.app.url }}"
- name: NEXT_AUTH_SECRET
  value: {{ randAlphaNum 32 | b64enc | quote }}
- name: NEXT_AUTH_SSO_PROVIDERS
  value: "authentik"
- name: NEXTAUTH_URL
  value: "{{ .Values.app.url }}"
- name: AUTH_AUTHENTIK_ID
  value: "{{ .Values.app.oidc.clientId }}"
- name: AUTH_AUTHENTIK_SECRET
  value: "{{ .Values.app.oidc.clientSecret }}"
- name: AUTH_AUTHENTIK_ISSUER
  value: "{{ .Values.app.oidc.issuer }}"
{{- end -}}
