{{/*
Expand the name of the chart.
*/}}
{{- define "plane.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "plane.fullname" -}}
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
{{- define "plane.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "plane.labels" -}}
helm.sh/chart: {{ include "plane.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- define "plane.api.labels" -}}
helm.sh/chart: {{ include "plane.chart" . }}
{{ include "plane.api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- define "plane.space.labels" -}}
helm.sh/chart: {{ include "plane.chart" . }}
{{ include "plane.space.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- define "plane.web.labels" -}}
helm.sh/chart: {{ include "plane.chart" . }}
{{ include "plane.web.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "plane.api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "plane.name" . }}-api
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- define "plane.space.selectorLabels" -}}
app.kubernetes.io/name: {{ include "plane.name" . }}-space
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- define "plane.web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "plane.name" . }}-web
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
API environment variables
*/}}
{{- define "plane.api.envVars" -}}
- name: PGUSER
  value: postgres
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-postgresql
      key: postgres-password
- name: PGHOST
  value: {{ include "plane.fullname" . }}-postgres
- name: PGDATABASE
  value: {{ .Values.postgresql.auth.database }}
- name: DATABASE_URL
  value: postgresql://{{ .Values.postgresql.auth.username }}:{{ .Values.postgresql.auth.password }}@{{ include "plane.fullname" . }}-postgresql/{{ .Values.postgresql.auth.database }}
- name: REDIS_HOST
  value: {{ include "plane.fullname" . }}-redis-master
- name: REDIS_PORT
  value: "6379"
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "plane.fullname" . }}-redis
      key: redis-password
- name: REDIS_URL
  value: "redis://:$(REDIS_PASSWORD)@$(REDIS_HOST):$(REDIS_PORT)"
- name: DOCKERIZED
  value: "1"
- name: ENABLE_SIGNUP
  value: "1"
- name: ENABLE_EMAIL_PASSWORD
  value: "1"
- name: SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "plane.fullname" . }}
      key: secret-key
- name: USE_MINIO
  value: '1'
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-minio
      key: root-user
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-minio
      key: root-password
- name: AWS_S3_ENDPOINT_URL
  value: http://{{ .Release.Name }}-minio:9000
- name: WEB_URL
  value: https://{{ .Values.ingress.host }}
{{- if .Values.smtp.enabled }}
- name: EMAIL_HOST
  value: {{ .Values.smtp.host }}
- name: EMAIL_HOST_USER
  value: {{ .Values.smtp.username | quote }}
- name: EMAIL_HOST_PASSWORD
  value: {{ .Values.smtp.password | quote }}
- name: EMAIL_PORT
  value: {{ .Values.smtp.port | quote }}
- name: EMAIL_FROM
  value: {{ .Values.smtp.from | quote }}
{{- end }}
{{- end }}