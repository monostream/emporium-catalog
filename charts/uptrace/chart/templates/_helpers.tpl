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