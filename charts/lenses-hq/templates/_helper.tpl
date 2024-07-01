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

{{- define "claimName" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 57 | trimSuffix "-") "claim" -}}
{{- else -}}
{{- printf "%s-%s" (.Release.Name | trunc 57 | trimSuffix "-") "claim" -}}
{{- end -}}
{{- end -}}

{{- define "sidecarProvisionImage" -}}
{{- if .Values.lenseshq.provision.sidecar.image.tag -}}
{{- printf "%s:%s" .Values.lenseshq.provision.sidecar.image.repository .Values.lenseshq.provision.sidecar.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.lenseshq.provision.sidecar.image.repository (regexFind "\\d+\\.\\d+" .Chart.AppVersion) -}}
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

{{- define "lensesHqOpts" -}}
{{- if .Values.lenseshq.opts.keyStoreFileData }}-Djavax.net.ssl.keyStore="/mnt/secrets/lenseshq.opts.keystore.jks" {{ end -}}
{{- if .Values.lenseshq.opts.keyStorePassword }}-Djavax.net.ssl.keyStorePassword="${CLIENT_OPTS_KEYSTORE_PASSWORD}" {{ end -}}
{{- if .Values.lenseshq.opts.trustStoreFileData }}-Djavax.net.ssl.trustStore="/mnt/secrets/lenseshq.opts.truststore.jks" {{ end -}}
{{- if .Values.lenseshq.opts.trustStorePassword }}-Djavax.net.ssl.trustStorePassword="${CLIENT_OPTS_TRUSTSTORE_PASSWORD}" {{ end -}}
{{- if .Values.lenseshq.lensesOpts }}{{- .Values.lenseshq.lensesOpts }}{{- end -}}
{{- end -}}

{{- define "lensesHqLogBackOpts" -}}
{{- if .Values.lenseshq.logbackXml }}-Dlogback.configurationFile="file:{{ .Values.lenseshq.logbackXml}}" {{ end -}}
{{- if .Values.lenseshq.jvm.logBackOpts }}{{- .Values.lenseshq.jvm.logBackOpts }}{{- end -}}
{{- end -}}

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
