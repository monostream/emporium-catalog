{{- define "wrapper.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: supabase
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

