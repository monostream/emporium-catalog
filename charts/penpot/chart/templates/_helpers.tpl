{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "penpot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "penpot.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "penpot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "penpot.labels" -}}
helm.sh/chart: {{ include "penpot.chart" . }}
app.kubernetes.io/name: {{ include "penpot.name" . }}-frontend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "penpot.frontendSelectorLabels" -}}
app.kubernetes.io/name: {{ include "penpot.name" . }}-frontend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- define "penpot.backendSelectorLabels" -}}
app.kubernetes.io/name: {{ include "penpot.name" . }}-backend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- define "penpot.exporterSelectorLabels" -}}
app.kubernetes.io/name: {{ include "penpot.name" . }}-exporter
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use.
*/}}
{{- define "penpot.serviceAccountName" -}}
{{- if .Values.serviceAccount.enabled -}}
    {{ default (include "penpot.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
PENPOT_SECRET_KEY, from the configured Secret.
*/}}
{{- define "penpot.secretKeyEnv" -}}
{{- if .Values.config.existingSecret }}
- name: PENPOT_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.existingSecret | quote }}
      key: {{ .Values.config.secretKeyKey | quote }}
{{- end }}
{{- end -}}

{{/*
PENPOT_REDIS_URI, from the configured Secret or the plain uri.
*/}}
{{- define "penpot.redisEnv" -}}
- name: PENPOT_REDIS_URI
{{- if .Values.config.redis.existingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.redis.existingSecret | quote }}
      key: {{ .Values.config.redis.uriKey | quote }}
{{- else }}
  value: {{ .Values.config.redis.uri | quote }}
{{- end }}
{{- end -}}

{{/*
S3 endpoint with the cluster domain appended to a "<svc>.<ns>.svc" host: the
frontend's nginx follows the backend's presigned redirects with its own
resolver, which does not apply search domains.
*/}}
{{- define "penpot.s3Endpoint" -}}
{{- $e := .Values.config.objectStorage.endpoint -}}
{{- if and (contains ".svc:" $e) (not (contains (printf ".svc.%s" .Values.clusterDomain) $e)) -}}
{{- replace ".svc:" (printf ".svc.%s:" .Values.clusterDomain) $e -}}
{{- else -}}
{{- $e -}}
{{- end -}}
{{- end -}}

{{/*
Internal URL of the frontend Service (the exporter renders through it, not
through the public ingress).
*/}}
{{- define "penpot.frontendURL" -}}
{{- printf "http://%s:%v" (include "penpot.fullname" .) .Values.frontend.service.port -}}
{{- end -}}

{{/*
Security contexts.
*/}}
{{- define "penpot.podSecurityContext" -}}
{{- if .enabled }}
securityContext:
  {{- omit . "enabled" | toYaml | nindent 2 }}
{{- end }}
{{- end -}}
