{{/*
Expand the name of the chart.
*/}}
{{- define "plane.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
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

{{- define "plane.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "plane.labels" -}}
helm.sh/chart: {{ include "plane.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels of one component: include "plane.selectorLabels" (list $ "api")
*/}}
{{- define "plane.selectorLabels" -}}
{{- $ := index . 0 -}}
app.kubernetes.io/name: {{ include "plane.name" $ }}-{{ index . 1 }}
app.kubernetes.io/instance: {{ $.Release.Name }}
{{- end }}

{{- define "plane.componentLabels" -}}
{{ include "plane.labels" (index . 0) }}
{{ include "plane.selectorLabels" . }}
{{- end }}

{{- define "plane.image" -}}
{{- $ := index . 0 -}}
{{- $img := index . 1 -}}
{{- printf "%s:%s" $img.repository ($img.tag | default $.Chart.AppVersion) -}}
{{- end }}

{{/*
Pod scheduling and security settings shared by every workload.
*/}}
{{- define "plane.podSpecCommon" -}}
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 2 }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{- define "plane.webURL" -}}
https://{{ required "ingress.host is required" .Values.ingress.host }}
{{- end }}

{{/*
Redis URL (cache, Celery broker, live server).
*/}}
{{- define "plane.redisEnv" -}}
- name: REDIS_URL
  valueFrom:
    secretKeyRef:
      name: {{ required "redis.existingSecret is required" .Values.redis.existingSecret }}
      key: {{ .Values.redis.urlKey }}
{{- end }}

{{/*
Backend environment (API, worker, beat, migrator).
*/}}
{{- define "plane.api.envVars" -}}
- name: DEBUG
  value: "0"
- name: DOCKERIZED
  value: "1"
- name: SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ required "secrets.existingSecret is required" .Values.secrets.existingSecret }}
      key: SECRET_KEY
- name: LIVE_SERVER_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.existingSecret }}
      key: LIVE_SERVER_SECRET_KEY
- name: PGHOST
  value: {{ required "database.host is required" .Values.database.host | quote }}
- name: PGPORT
  value: {{ .Values.database.port | toString | quote }}
- name: PGDATABASE
  value: {{ .Values.database.name | quote }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ required "database.existingSecret is required" .Values.database.existingSecret }}
      key: {{ .Values.database.usernameKey }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.database.existingSecret }}
      key: {{ .Values.database.passwordKey }}
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.database.existingSecret }}
      key: {{ .Values.database.uriKey }}
{{ include "plane.redisEnv" . }}
# Celery accepts a redis:// broker URL, so Plane needs no RabbitMQ.
- name: AMQP_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.redis.existingSecret }}
      key: {{ .Values.redis.urlKey }}
- name: USE_MINIO
  value: "1"
# Presigned upload/download URLs point at https://<host>/<bucket>.
- name: MINIO_ENDPOINT_SSL
  value: "1"
- name: AWS_S3_ENDPOINT_URL
  value: {{ required "objectStorage.endpoint is required" .Values.objectStorage.endpoint | quote }}
- name: AWS_REGION
  value: {{ .Values.objectStorage.region | quote }}
- name: AWS_S3_BUCKET_NAME
  value: {{ .Values.objectStorage.bucket | quote }}
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ required "objectStorage.existingSecret is required" .Values.objectStorage.existingSecret }}
      key: {{ required "objectStorage.accessKeyKey is required" .Values.objectStorage.accessKeyKey }}
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.objectStorage.existingSecret }}
      key: {{ required "objectStorage.secretKeyKey is required" .Values.objectStorage.secretKeyKey }}
- name: FILE_SIZE_LIMIT
  value: {{ .Values.app.fileSizeLimit | int | toString | quote }}
- name: WEB_URL
  value: {{ include "plane.webURL" . | quote }}
- name: CORS_ALLOWED_ORIGINS
  value: {{ include "plane.webURL" . | quote }}
- name: ENABLE_SIGNUP
  value: {{ ternary "1" "0" .Values.app.enableSignup | quote }}
- name: ENABLE_EMAIL_PASSWORD
  value: "1"
{{- if .Values.smtp.enabled }}
- name: EMAIL_HOST
  value: {{ .Values.smtp.host | quote }}
- name: EMAIL_HOST_USER
  value: {{ .Values.smtp.username | quote }}
- name: EMAIL_HOST_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ required "smtp.existingSecret is required" .Values.smtp.existingSecret }}
      key: {{ required "smtp.passwordKey is required" .Values.smtp.passwordKey }}
- name: EMAIL_PORT
  value: {{ .Values.smtp.port | toString | quote }}
- name: EMAIL_FROM
  value: {{ .Values.smtp.from | quote }}
- name: EMAIL_USE_TLS
  value: {{ ternary "0" "1" .Values.smtp.useSSL | quote }}
- name: EMAIL_USE_SSL
  value: {{ ternary "1" "0" .Values.smtp.useSSL | quote }}
{{- end }}
{{- end }}
