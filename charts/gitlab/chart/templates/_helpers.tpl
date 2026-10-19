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

{{/*
Images of the runner setup Job: gitlab-base runs the toolbox's configure
script, the toolbox image runs `gitlab-rails runner`
*/}}
{{- define "gitlab.emporium.gitlabBaseImage" -}}
{{- $image := .Values.emporium.images.gitlabBase -}}
{{- printf "%s:%s" $image.repository (default .Chart.AppVersion $image.tag) }}
{{- end }}

{{- define "gitlab.emporium.toolboxImage" -}}
{{- $image := .Values.emporium.images.toolbox -}}
{{- printf "%s-%s:%s" $image.repository (default "ce" .Values.global.edition) (default .Chart.AppVersion $image.tag) }}
{{- end }}

{{/*
Secrets the toolbox's configure script copies to /etc/gitlab and the rendered
configuration (gitlab.yml, database.yml, resque.yml, cable.yml) reads. Mirrors
the init-toolbox-secrets volume of the upstream toolbox Deployment for the
features this chart uses; the names follow the upstream defaults.
*/}}
{{- define "gitlab.emporium.toolboxSecrets" -}}
{{- $g := .Values.gitlab.global -}}
{{- $rel := .Release.Name -}}
- secret:
    name: {{ dig "railsSecrets" "secret" "" $g | default (printf "%s-rails-secret" $rel) | quote }}
    items:
      - key: secrets.yml
        path: rails-secrets/secrets.yml
- secret:
    name: {{ dig "shell" "authToken" "secret" "" $g | default (printf "%s-gitlab-shell-secret" $rel) | quote }}
    items:
      - key: {{ dig "shell" "authToken" "key" "" $g | default "secret" | quote }}
        path: shell/.gitlab_shell_secret
- secret:
    name: {{ dig "gitaly" "authToken" "secret" "" $g | default (printf "%s-gitaly-secret" $rel) | quote }}
    items:
      - key: {{ dig "gitaly" "authToken" "key" "" $g | default "token" | quote }}
        path: gitaly/gitaly_token
{{- if dig "redis" "auth" "enabled" false $g }}
- secret:
    name: {{ dig "redis" "auth" "secret" "" $g | default (printf "%s-redis-secret" $rel) | quote }}
    items:
      - key: {{ dig "redis" "auth" "key" "" $g | default "secret" | quote }}
        path: redis/redis-password
{{- end }}
{{- range $schema := list "ci" "main" }}
- secret:
    name: {{ required "global.psql.password.secret is required" (dig "psql" "password" "secret" "" $g) | quote }}
    items:
      - key: {{ dig "psql" "password" "key" "" $g | default "postgresql-password" | quote }}
        path: postgres/psql-password-{{ $schema }}
{{- end }}
- secret:
    name: {{ dig "registry" "certificate" "secret" "" $g | default (printf "%s-registry-secret" $rel) | quote }}
    items:
      - key: registry-auth.key
        path: registry/gitlab-registry.key
- secret:
    name: {{ dig "registry" "notificationSecret" "secret" "" $g | default (printf "%s-registry-notification" $rel) | quote }}
    items:
      - key: {{ dig "registry" "notificationSecret" "key" "" $g | default "secret" | quote }}
        path: registry/notificationSecret
{{- if or (dig "kas" "enabled" false $g) (dig "appConfig" "gitlab_kas" "enabled" false $g) }}
- secret:
    name: {{ dig "appConfig" "gitlab_kas" "secret" "" $g | default (printf "%s-gitlab-kas-secret" $rel) | quote }}
    items:
      - key: {{ dig "appConfig" "gitlab_kas" "key" "" $g | default "kas_shared_secret" | quote }}
        path: kas/.gitlab_kas_secret
{{- end }}
{{- with dig "appConfig" "object_store" "connection" dict $g }}
- secret:
    name: {{ .secret | quote }}
    items:
      - key: {{ default "connection" .key | quote }}
        path: objectstorage/object_store
{{- end }}
{{- with dig "smtp" dict $g }}
{{- if and .enabled (ne "none" (.authentication | default "none")) }}
- secret:
    name: {{ required "global.smtp.password.secret is required" (dig "password" "secret" "" .) | quote }}
    items:
      - key: {{ dig "password" "key" "" . | default "password" | quote }}
        path: smtp/smtp-password
{{- with dig "user_name_secret" "secret" "" . }}
- secret:
    name: {{ . | quote }}
    items:
      - key: {{ dig "user_name_secret" "key" "" $g.smtp | default "username" | quote }}
        path: smtp/smtp-username
{{- end }}
{{- end }}
{{- end }}
{{- range dig "appConfig" "omniauth" "providers" list $g }}
{{- if hasKey . "secret" }}
- secret:
    name: {{ .secret | quote }}
    items:
      - key: {{ default "provider" .key | quote }}
        path: {{ printf "omniauth/%s/%s" .secret (default "provider" .key) | quote }}
{{- end }}
{{- end }}
{{- end }}
