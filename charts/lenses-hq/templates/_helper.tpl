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
{{- end }}
{{- end }}