{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "fullname" -}}
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

{{- define "lensesHqImage" -}}
{{- if .Values.image.tag -}}
{{ printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- else -}}
{{ printf "%s:%s" .Values.image.repository .Chart.AppVersion  }}
{{- end -}}
{{- end -}}

{{- define "nodePort" -}}
{{- if and .Values.service.nodePort .Values.nodePort -}}
{{- if eq .Values.service.nodePort .Values.nodePort -}}
{{- .Values.service.nodePort -}}
{{- else -}}
{{ fail "You cannot set two differents nodePort port inside your configuration"}}
{{- end -}}
{{- else -}}
{{- if .Values.nodePort }}
{{- .Values.nodePort -}}
{{- else if .Values.service.nodePort -}}
{{- .Values.service.nodePort -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "databaseSecretName" -}}
{{- if .Values.nameOverride }}
  {{- printf "%s-%s" .Values.nameOverride "db-secret" | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- printf "%s-%s" .Chart.Name "db-secret" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" -}}
{{- print "networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "validate.singleEnabledDatabase" -}}
{{- $enabledCount := 0 -}}
{{- range $name, $db := .Values.lensesHq.storage }}
  {{- if $db.enabled }}
    {{- $enabledCount = add $enabledCount 1 -}}
  {{- end }}
{{- end }}
{{- if gt $enabledCount 1 }}
  {{- fail "Only one database can be enabled at a time. Please check your configuration in values.yaml." -}}
{{ else if eq $enabledCount 0 }}
  {{- fail "Database is not enabled as a storage method for HQ. Please check your configuration in values.yaml." -}}
{{- end }}
{{- end }}

{{- define "extractPort" -}}
{{- $address := printf "%s" . -}}
{{- regexReplaceAll ".*:(\\d+)$" $address "$1" | int -}}
{{- end -}}

{{- define "lensesHqConfigmap" -}}
auth:
  administrators:
  {{- range .Values.lensesHq.auth.administrators }}
    - {{ . }}
  {{- end }}
  users:
  {{- range .Values.lensesHq.auth.users }}
    - username: {{ .username }}
      password: {{ .password }}
  {{- end }}
  sessionDuration: {{ .Values.lensesHq.auth.sessionDuration }}
  saml:
    enabled: {{ .Values.lensesHq.auth.saml.enabled }}
    {{- if (.Values.lensesHq.auth.saml).enabled }}
    baseURL: {{ .Values.lensesHq.auth.saml.baseURL }}
    entityID: {{ .Values.lensesHq.auth.saml.entityID }}
    {{- if .Values.lensesHq.auth.saml.metadata.referenceFromSecret }}
    metadata: $(LENSESHQ_AUTH_SAML_METADATA)
    {{- else }}
    metadata: {{ .Values.lensesHq.auth.saml.metadata.stringData | indent 10 }}
    {{- end }}
    userCreationMode: {{ .Values.lensesHq.auth.saml.userCreationMode }}
    groupMembershipMode: {{ .Values.lensesHq.auth.saml.usersGroupMembershipManagementMode }}
    uiRootURL: {{ .Values.lensesHq.auth.saml.uiRootURL }}
    groupAttributeKey: {{ .Values.lensesHq.auth.saml.groupAttributeKey }}
    {{- end }}
    authnRequestSignature:
      enabled: {{ .Values.lensesHq.auth.saml.authnRequestSignature.enabled -}}
      {{- if (.Values.lensesHq.auth.saml.authnRequestSignature).enabled }}
      {{- if (.Values.lensesHq.auth.saml.authnRequestSignature.authnRequestSigningCert).referenceFromSecret }}
      cert: $(LENSESHQ_AUTH_SAML_SIGNREQ_CERT)
      {{- else }}
      {{ if (not (empty .Values.lensesHq.auth.saml.authnRequestSignature.authnRequestSigningCert.stringData)) }}
      cert: |-
{{ .Values.lensesHq.auth.saml.authnRequestSignature.authnRequestSigningCert.stringData | indent 8 }}
      {{- end }}
      {{- end }}
      {{ if (not (empty .Values.lensesHq.auth.saml.authnRequestSignature.authnRequestSigningKey.secret.name)) }}
      key: $(LENSESHQ_AUTH_SAML_SIGNREQ_KEY)
      {{- end -}}
      {{- end }}
http:
  address: {{ .Values.lensesHq.http.address }}
  accessControlAllowOrigin:
  {{- range .Values.lensesHq.http.accessControlAllowOrigin }}
    - {{ . }}
  {{- end }}
  accessControlAllowCredentials: {{ .Values.lensesHq.http.accessControlAllowCredentials }}
  secureSessionCookies: {{ .Values.lensesHq.http.secureSessionCookies }}
  {{ if (.Values.lensesHq.http.tls).enabled }}
  tls:
    enabled: {{ .Values.lensesHq.http.tls.enabled -}}
    {{ if (.Values.lensesHq.http.tls.cert).referenceFromSecret }}
    cert: $(LENSESHQ_HTTP_TLS_CERT)
    {{- else }}
    cert: |-
{{ .Values.lensesHq.http.tls.cert.stringData | indent 10 }}
    {{ end }}
    key: $(LENSESHQ_HTTP_TLS_KEY)
    verboseLogs: {{ .Values.lensesHq.http.tls.verboseLogs }}
    {{ end }}
agents:
  address: {{ .Values.lensesHq.agents.address }}
  {{ if (.Values.lensesHq.agents.tls).enabled }}
  tls:
    enabled: {{ .Values.lensesHq.agents.tls.enabled }}
    {{ if (.Values.lensesHq.agents.tls.cert).referenceFromSecret }}
    cert: $(LENSESHQ_AGENTS_TLS_CERT)
    {{- else }}
    cert: |-
{{ .Values.lensesHq.agents.tls.cert.stringData | indent 10 }}
    {{ end }}
    key: $(LENSESHQ_AGENTS_TLS_KEY)
    verboseLogs: {{ .Values.lensesHq.agents.tls.verboseLogs }}
    {{ end }}
database:
  {{- include "validate.singleEnabledDatabase" . -}}
{{- range $name, $db := .Values.lensesHq.storage }}
  {{- if $db.enabled }}
  host: {{ $db.host }}:{{ $db.port }}
  username: $(LENSESHQ_PG_USERNAME)
  password: $(LENSESHQ_PG_PASSWORD)
  schema: {{ $db.schema }}
  database: {{ $db.database }}
  {{- if $db.params }}
  params:
{{ toYaml $db.params | indent 8 }}
  {{- end }}
  TLS: {{ $db.tls }}
  {{- end }}
{{- end }}
license:
  {{- if .Values.lensesHq.license.referenceFromSecret }}
  key: $(LENSESHQ_LICENSE)
  {{- else }}
  key: {{ .Values.lensesHq.license.stringData | indent 6 }}
  {{- end }}
  acceptEULA: {{ .Values.lensesHq.license.acceptEULA }}
logger:
  mode: {{ .Values.lensesHq.logger.mode }}
  level: {{ default "info" .Values.lensesHq.logger.level }}
metrics:
  prometheusAddress: {{ .Values.lensesHq.metrics.prometheusAddress }}

{{- end }}
