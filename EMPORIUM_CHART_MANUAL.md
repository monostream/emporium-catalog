# Emporium Chart Creation Manual

## Overview

Emporium is a platform for self-hosted applications that simplifies the deployment and management of Helm charts. This manual covers everything you need to know to create Emporium-compatible charts.

## Table of Contents

1. [Repository Structure](#repository-structure)
2. [Chart Structure](#chart-structure)
3. [Required Files](#required-files)
4. [Emporium Integrations](#emporium-integrations)
5. [User-Supplied Variables](#user-supplied-variables)
6. [Emporium Annotations](#emporium-annotations)
7. [Chart.yaml Configuration](#chartyaml-configuration)
8. [Template Variables](#template-variables)
9. [Common Patterns](#common-patterns)
10. [Best Practices](#best-practices)
11. [Examples](#examples)
12. [Troubleshooting](#troubleshooting)

---

## Repository Structure

Each chart follows a consistent directory structure:

```
charts/
├── [chart-name]/
│   ├── chart/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   ├── values.emporium.yaml
│   │   ├── README.md
│   │   └── templates/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       ├── ingress.yaml
│   │       ├── NOTES.txt
│   │       └── _helpers.tpl
│   └── deps.json
└── assets/
    └── [chart-name]/
        ├── [chart-name]_icon_1.svg
        ├── [chart-name]_icon_2.svg
        ├── [chart-name]_icon_3.svg
        └── [chart-name]_gallery_*.{jpg,png,webp}
```

---

## Chart Structure

### Required Files

#### 1. `Chart.yaml`
The main chart metadata file containing:
- Basic chart information (name, version, description)
- Dependencies (if any)
- Emporium-specific annotations

#### 2. `values.emporium.yaml`
The **lean** Emporium-specific values file (located in the `chart/` directory) that should **only** contain:
- User-supplied variables with documentation (using @userSupplied annotations)
- Emporium integration configurations (DNS, OIDC, SMTP, Storage)
- Values that **differ** from those in `values.yaml`

**Important**: `values.yaml` serves as the base configuration. Do **NOT** duplicate values that are identical between `values.yaml` and `values.emporium.yaml`. Only include Emporium-specific overrides and integrations.

#### 3. `deps.json`
Dependency management file for chart lifecycle:
```json
[
  {
    "provider": "chart",
    "name": "chart-name",
    "repo": "./chart",
    "allowPrerelease": false,
    "appVersionMapping": "dependency:chart-name",
    "changelogPath": "./chart"
  }
]
```

#### 4. `README.md`
Simple, app-store-style documentation (located in the `chart/` directory) that should:
- Focus on features and benefits
- Use emojis and bullet points for readability
- Include "Perfect For" use cases
- Be concise and marketing-focused (not technical documentation)
- Highlight key features that users care about

#### 5. Assets
Visual assets for the Emporium marketplace:
- **Icons**: 3 SVG icons (`_icon_1.svg`, `_icon_2.svg`, `_icon_3.svg`)
- **Gallery**: Screenshots/previews in various formats

---

## Emporium Integrations

Emporium provides four main integrations that charts can use:

### 1. DNS Integration
```yaml
# Access hostname
{{ .Emporium.Integrations.DNS.Hostname }}
# Access zone (for special cases)
{{ .Emporium.Integrations.DNS.Zone }}
```

### 2. OIDC Integration
```yaml
# OIDC Configuration
{{ .Emporium.Integrations.OIDC.Issuer }}
{{ .Emporium.Integrations.OIDC.ClientID }}
{{ .Emporium.Integrations.OIDC.ClientSecret }}
{{ .Emporium.Integrations.OIDC.ConfigurationEndpoint }}
```

### 3. SMTP Integration
```yaml
# SMTP Configuration
{{ .Emporium.Integrations.SMTP.Host }}
{{ .Emporium.Integrations.SMTP.Port }}
{{ .Emporium.Integrations.SMTP.Username }}
{{ .Emporium.Integrations.SMTP.Password }}
{{ .Emporium.Integrations.SMTP.From }}
{{ .Emporium.Integrations.SMTP.ReplyTo }}
```

### 4. Storage Integration
```yaml
# Storage Claims
{{ .Emporium.Integrations.Storage.Claims.Data.Name }}
```

---

## User-Supplied Variables

User-supplied variables allow end-users to customize the application. They are defined using special comments in `values.emporium.yaml`:

### Basic Syntax
```yaml
## @userSupplied VariableName
## @label Display Name
## @type string|integer|boolean|byteSize|storageClass
## @description Description for the user
## @optional (if the field is optional)
```

### Variable Types
- `string`: Text input
- `integer`: Numeric input
- `boolean`: Checkbox
- `byteSize`: Storage size (e.g., "10Gi")
- `storageClass`: Kubernetes storage class selector

### Usage Examples
```yaml
## @userSupplied Username
## @label Admin Username
## @type string
## @description The administrator username
username: {{ .Emporium.UserSupplied.Username }}

## @userSupplied StorageSize
## @label Storage Size
## @type byteSize
## @description Size of the storage volume
## @optional
storageSize: {{ default "10Gi" .Emporium.UserSupplied.StorageSize }}

## @userSupplied EnableFeature
## @label Enable Feature
## @type boolean
## @description Enable advanced features
## @optional
enableFeature: {{ default false .Emporium.UserSupplied.EnableFeature }}
```

---

## Emporium Annotations

Emporium provides several special annotations for ingress configurations:

### Core Annotations
```yaml
annotations:
  {{- if .Emporium.Annotations }}
  {{- toYaml .Emporium.Annotations | nindent 4 }}
  {{- end }}
  kubernetes.io/tls-acme: "true"
```

### Auth Control Annotations
```yaml
# Skip authentication for specific paths
emporium.build/auth-skip-paths: '/api/*,/#/*'

# Skip authentication for all paths
emporium.build/auth-skip-paths: '/*'

# Use regex patterns
emporium.build/auth-skip-paths: 'regex(^(\/([^\/\n])+){2,}\.git.*$)'

# Disable the glass/overlay UI
emporium.build/disable-glass: "true"
```

### Common Nginx Annotations
```yaml
# For file uploads
nginx.ingress.kubernetes.io/proxy-body-size: "16m"

# For Git operations
nginx.ingress.kubernetes.io/proxy-body-size: "0"
nginx.ingress.kubernetes.io/proxy-connect-timeout: "15"
nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
nginx.ingress.kubernetes.io/service-upstream: "true"
```

---

## Chart.yaml Configuration

### Basic Structure
```yaml
apiVersion: v2
name: chart-name
description: Brief description of the application
version: 0.1.0
appVersion: "1.0.0"
type: application
home: https://project-homepage.com
icon: https://raw.githubusercontent.com/monostream/test-charts/main/assets/chart-name/chart-name_icon_2.svg
sources:
  - https://github.com/project/repo
keywords:
  - Category1
  - Category2
maintainers:
  - name: Maintainer Name
    url: https://github.com/maintainer
```

### Emporium Annotations
```yaml
annotations:
  displayName: "Human Readable Name"
  category: "Category Name"
  licenses: "MIT"
  gallery: |
    https://raw.githubusercontent.com/monostream/test-charts/main/assets/chart-name/chart-name_gallery_1.png
    https://raw.githubusercontent.com/monostream/test-charts/main/assets/chart-name/chart-name_gallery_2.png
  oidcRedirectPaths: "/auth/callback"  # For OIDC apps
```

### Categories
Common categories include:
- Developer Tools
- AI
- Utilities
- Storage
- Monitoring
- Observability
- Testing
- Integration

---

## Template Variables

### Emporium Context Variables
```yaml
# Application name
{{ .Emporium.Name }}

# Standard ingress configuration
ingress:
  enabled: true
  annotations:
    {{- if .Emporium.Annotations }}
    {{- toYaml .Emporium.Annotations | nindent 4 }}
    {{- end }}
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: {{ .Emporium.Integrations.DNS.Hostname }}
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: {{ .Emporium.Name }}-tls
      hosts:
        - {{ .Emporium.Integrations.DNS.Hostname }}
```

### Template Functions
```yaml
# Default values
{{ default "defaultValue" .Emporium.UserSupplied.VariableName }}

# Conditional logic
{{ if .Emporium.UserSupplied.EnableFeature }}
enabled: true
{{ else }}
enabled: false
{{ end }}

# Ternary operator
{{ ternary "value-if-true" "value-if-false" .Emporium.UserSupplied.BooleanVar }}

# String operations
{{ .Emporium.UserSupplied.StringVar | quote }}
```

---

## Common Patterns

### 1. Basic Web Application
```yaml
ingress:
  enabled: true
  annotations:
    {{- if .Emporium.Annotations }}
    {{- toYaml .Emporium.Annotations | nindent 4 }}
    {{- end }}
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: {{ .Emporium.Integrations.DNS.Hostname }}
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: {{ .Emporium.Name }}-tls
      hosts:
        - {{ .Emporium.Integrations.DNS.Hostname }}
```

### 2. Application with Database
```yaml
global:
  postgresqlEnabled: true

postgresql:
  fullnameOverride: "{{ .Emporium.Name }}-postgresql"
  auth:
    existingSecret: "{{ .Emporium.Name }}-postgresql"
```

### 3. Application with Storage
```yaml
persistence:
  enabled: true
  existingClaim: "{{ .Emporium.Integrations.Storage.Claims.Data.Name }}"
```

### 4. Application with OIDC
```yaml
oidc:
  enabled: true
  issuer: "{{ .Emporium.Integrations.OIDC.Issuer }}"
  clientId: "{{ .Emporium.Integrations.OIDC.ClientID }}"
  clientSecret: "{{ .Emporium.Integrations.OIDC.ClientSecret }}"
```

### 5. Application with Email
```yaml
smtp:
  enabled: true
  host: {{ .Emporium.Integrations.SMTP.Host }}
  port: {{ .Emporium.Integrations.SMTP.Port | quote }}
  username: {{ .Emporium.Integrations.SMTP.Username | quote }}
  password: {{ .Emporium.Integrations.SMTP.Password | quote }}
  from: {{ .Emporium.Integrations.SMTP.From | quote }}
```

### 6. Security Context Configuration
Always configure security context to match the container's user. Check the Dockerfile for user details:

```dockerfile
# Example from Dockerfile
ENV USER=app
ENV UID=10001
USER app:app
```

Configure security context accordingly:
```yaml
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 10001
  runAsGroup: 10001
  fsGroup: 10001

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false  # or true with tmpfs volumes
  runAsNonRoot: true
  runAsUser: 10001
  runAsGroup: 10001
  capabilities:
    drop:
      - ALL
```

### 7. Application Limits and Ingress Annotations
Always match application limits with corresponding ingress annotations:

```yaml
# Application configuration
app:
  env:
    MAX_BODY_SIZE: "16777216"  # 16MB

# Ingress configuration
ingress:
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "16m"  # Match the app limit
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
```

---

## Best Practices

### 1. User Experience
- Always provide sensible defaults for optional fields
- Use clear, descriptive labels for user-supplied variables
- Group related configuration options together
- Provide helpful descriptions for complex options

### 2. Security
- Never expose sensitive information in defaults
- Use appropriate authentication skip paths
- Implement proper OIDC integration when applicable
- Use TLS/SSL certificates automatically
- **Always configure security context to match the container's user**
- Use non-root users and drop unnecessary capabilities
- Set appropriate filesystem permissions with fsGroup
- **Match application limits with ingress annotations** (e.g., body size limits)

### 3. Configuration Management
- Use the `@optional` annotation for non-essential fields
- Provide reasonable defaults using the `default` function
- Use proper data types for user inputs
- Document all configuration options

### 4. Lean values.emporium.yaml (NEW)
- **Keep values.emporium.yaml minimal** - only include Emporium-specific configurations
- **Do NOT duplicate** values that are identical in `values.yaml` and `values.emporium.yaml`
- **Only include**:
  - User-supplied variables with `@userSupplied` annotations
  - Emporium integrations (DNS, OIDC, SMTP, Storage templates)
  - Values that differ from `values.yaml` defaults
  - Emporium-specific overrides (like ingress with auth-skip-paths)
- Remember: `values.yaml` serves as the base, `values.emporium.yaml` adds/overrides

### 5. Template Structure
- Keep templates clean and readable
- Use consistent indentation (typically 2 spaces)
- Use conditional blocks for optional features
- Comment complex template logic

### 6. Dependencies
- Keep dependencies minimal and necessary
- Use stable dependency versions
- Document any external dependencies
- Test with different dependency versions

---

## Examples

### Lean values.emporium.yaml Example

#### ❌ Incorrect (Too Verbose)
```yaml
# BAD: Duplicates everything from values.yaml
nameOverride: ""
fullnameOverride: ""

image:
  repository: myapp/image
  tag: "latest"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

resources:
  limits:
    cpu: 500m
    memory: 512Mi

# Only these are actually needed for Emporium!
ingress:
  enabled: true
  annotations:
    {{- if .Emporium.Annotations }}
    {{- toYaml .Emporium.Annotations | nindent 4 }}
    {{- end }}
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: {{ .Emporium.Integrations.DNS.Hostname }}
```

#### ✅ Correct (Lean Approach)
```yaml
# GOOD: Only Emporium-specific configurations
ingress:
  enabled: true
  annotations:
    {{- if .Emporium.Annotations }}
    {{- toYaml .Emporium.Annotations | nindent 4 }}
    {{- end }}
    kubernetes.io/tls-acme: "true"
    # Emporium-specific annotation
    emporium.build/auth-skip-paths: "/*"
  hosts:
    - host: {{ .Emporium.Integrations.DNS.Hostname }}
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: {{ .Emporium.Name }}-tls
      hosts:
        - {{ .Emporium.Integrations.DNS.Hostname }}
```

### Simple Static Website
```yaml
## @userSupplied BasePath
## @label Base Path
## @type string
## @description The base path for the website
## @optional

basePath: {{ default "/" .Emporium.UserSupplied.BasePath }}

ingress:
  enabled: true
  annotations:
    {{- if .Emporium.Annotations }}
    {{- toYaml .Emporium.Annotations | nindent 4 }}
    {{- end }}
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: {{ .Emporium.Integrations.DNS.Hostname }}
      paths:
        - path: {{ .Emporium.UserSupplied.BasePath | default "/" }}
          pathType: Prefix
  tls:
    - secretName: {{ .Emporium.Name }}-tls
      hosts:
        - {{ .Emporium.Integrations.DNS.Hostname }}
```

### Application with Admin User
```yaml
## @userSupplied AdminUsername
## @label Admin Username
## @type string
## @description Administrator username

## @userSupplied AdminPassword
## @label Admin Password
## @type string
## @description Administrator password

app:
  admin:
    username: {{ .Emporium.UserSupplied.AdminUsername }}
    password: {{ .Emporium.UserSupplied.AdminPassword }}
    email: 'admin@{{ .Emporium.Integrations.DNS.Hostname }}'
```

### Application with Storage Options
```yaml
## @userSupplied StorageSize
## @label Storage Size
## @type byteSize
## @description Size of the storage volume
## @optional

## @userSupplied StorageClass
## @label Storage Class
## @type storageClass
## @description Kubernetes storage class to use
## @optional

persistence:
  enabled: true
  size: {{ default "10Gi" .Emporium.UserSupplied.StorageSize }}
  {{- if .Emporium.UserSupplied.StorageClass }}
  storageClass: {{ .Emporium.UserSupplied.StorageClass }}
  {{- end }}
```

---

## Troubleshooting

### Common Issues

1. **Template Rendering Errors**
   - Check for missing quotes around string values
   - Verify all required user-supplied variables are defined
   - Ensure proper indentation in YAML

2. **Authentication Issues**
   - Verify `auth-skip-paths` annotations are correctly configured
   - Check if OIDC configuration is properly set up
   - Ensure DNS hostname is accessible

3. **Storage Problems**
   - Verify storage class exists in the cluster
   - Check if storage claims are properly referenced
   - Ensure storage size format is correct (e.g., "10Gi")

4. **Dependency Issues**
   - Check if all dependencies are properly defined in `Chart.yaml`
   - Verify dependency versions are compatible
   - Update `deps.json` if needed

### Debugging Tips

1. **Use `helm template` to test rendering**
   ```bash
   helm template my-release ./chart --values values.emporium.yaml
   ```

2. **Check Emporium logs for specific errors**

3. **Validate YAML syntax**
   ```bash
   yamllint values.emporium.yaml
   ```

4. **Test with minimal configuration first**

---

## Resources

- [Emporium Documentation](https://emporium.build/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Go Template Documentation](https://pkg.go.dev/text/template)

---

## Conclusion

This manual provides a comprehensive guide to creating Emporium charts. The key to success is understanding the integration patterns, properly configuring user-supplied variables, and following the established conventions for chart structure and metadata.

Remember to:
- Always test your charts thoroughly
- Provide clear documentation for end-users
- Use the Emporium integrations effectively
- Follow security best practices
- Keep configurations simple and intuitive

For additional help or questions, refer to the Emporium documentation or community resources. 