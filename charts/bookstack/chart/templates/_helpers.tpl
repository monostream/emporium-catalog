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

{{- define "chart.mariadb.fullname" -}}
{{- printf "%s-mariadb" (include "chart.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "chart.mariadb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}-mariadb
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "chart.mariadb.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "chart.mariadb.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- /* Environment shared by the BookStack container and its init container. */ -}}
{{- define "chart.env" -}}
- name: APP_URL
  value: {{ required "config.appUrl is set by the ingress integration" .Values.config.appUrl | quote }}
- name: APP_KEY
  valueFrom:
    secretKeyRef:
      name: {{ required "app.existingSecret is required" .Values.app.existingSecret | quote }}
      key: {{ .Values.app.keyKey | quote }}
- name: DB_HOST
  value: {{ printf "%s:3306" (include "chart.mariadb.fullname" .) | quote }}
- name: DB_DATABASE
  value: {{ .Values.mariadb.database | quote }}
- name: DB_USERNAME
  value: {{ .Values.mariadb.user | quote }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ required "mariadb.auth.existingSecret is required" .Values.mariadb.auth.existingSecret | quote }}
      key: {{ .Values.mariadb.auth.passwordKey | quote }}
# Behind the ingress: trust X-Forwarded-* so BookStack builds https links.
- name: APP_PROXIES
  value: "*"
# Sessions in the database survive pod restarts.
- name: SESSION_DRIVER
  value: database
- name: CACHE_DRIVER
  value: file
{{- end }}

{{- define "chart.uploadMounts" -}}
- name: uploads
  mountPath: /var/www/bookstack/public/uploads
  subPath: public-uploads
- name: uploads
  mountPath: /var/www/bookstack/storage/uploads
  subPath: storage-uploads
{{- end }}
