{{- define "plausible.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "plausible.fullname" -}}
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

{{- define "plausible.clickhouse" -}}
{{- printf "%s-clickhouse" (include "plausible.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "plausible.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "plausible.labels" -}}
helm.sh/chart: {{ include "plausible.chart" . }}
app.kubernetes.io/name: {{ include "plausible.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "plausible.selectorLabels" -}}
app.kubernetes.io/name: {{ include "plausible.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: web
{{- end }}

{{- define "plausible.clickhouseSelectorLabels" -}}
app.kubernetes.io/name: {{ include "plausible.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: clickhouse
{{- end }}

{{- define "plausible.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "plausible.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "plausible.clickhouseClaim" -}}
{{- default (include "plausible.clickhouse" .) .Values.clickhouse.persistence.existingClaim }}
{{- end }}
