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
Name of a resource of this release, e.g. "gitlab.emporium.name" (list . "object-storage")
*/}}
{{- define "gitlab.emporium.name" -}}
{{- printf "%s-%s" (index . 0).Release.Name (index . 1) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
In-cluster S3 endpoint of the bundled RustFS (host:port)
*/}}
{{- define "gitlab.emporium.s3Host" -}}
{{- $fullname := default (printf "%s-rustfs" .Release.Name) .Values.rustfs.fullnameOverride -}}
{{- printf "%s-svc.%s.svc:%v" $fullname .Release.Namespace .Values.rustfs.service.endpoint.port }}
{{- end }}

{{/*
Value of a key of an existing Secret, or a new random value. Keeps generated
credentials stable across upgrades. Usage:
  include "gitlab.emporium.secretValue" (dict "secret" $existing "key" "password" "length" 32)
*/}}
{{- define "gitlab.emporium.secretValue" -}}
{{- $data := dig "data" dict (default dict .secret) -}}
{{- if hasKey $data .key -}}
{{- index $data .key | b64dec -}}
{{- else -}}
{{- randAlphaNum (int .length) -}}
{{- end -}}
{{- end }}

{{/*
Image of the kubectl tool used by the setup Jobs
*/}}
{{- define "gitlab.emporium.kubectlImage" -}}
{{- $image := .Values.emporium.images.kubectl -}}
{{- printf "%s:%s" $image.repository (default .Chart.AppVersion $image.tag) }}
{{- end }}
