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

{{- define "provisionFullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 53 | trimSuffix "-") "provision" -}}
{{- else -}}
{{- printf "%s-%s" (.Release.Name | trunc 53 | trimSuffix "-") "provision" -}}
{{- end -}}
{{- end -}}

{{- define "storageH2ClaimName" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 57 | trimSuffix "-") "storageclaim" -}}
{{- else -}}
{{- printf "%s-%s" (.Release.Name | trunc 57 | trimSuffix "-") "storageh2claim" -}}
{{- end -}}
{{- end -}}

{{- define "logsClaimName" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 57 | trimSuffix "-") "logsclaim" -}}
{{- else -}}
{{- printf "%s-%s" (.Release.Name | trunc 57 | trimSuffix "-") "logsclaim" -}}
{{- end -}}
{{- end -}}

{{- define "lensesAgentImage" -}}
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

{{- define "metricTopic" -}}
{{- if .Values.lensesAgent.topics.suffix -}}
_kafka_lenses_metrics_{{ .Values.lensesAgent.topics.suffix }}
{{- else -}}
_kafka_lenses_metrics
{{- end -}}
{{- end -}}

{{- define "topologyTopic" -}}
{{- if .Values.lensesAgent.topics.suffix -}}
__topology_{{ .Values.lensesAgent.topics.suffix }}
{{- else -}}
__topology
{{- end -}}
{{- end -}}

{{- define "externalMetricsTopic" -}}
{{- if .Values.lensesAgent.topics.suffix -}}
__topology__metrics_{{ .Values.lensesAgent.topics.suffix }}
{{- else -}}
__topology__metrics
{{- end -}}
{{- end -}}


{{- define "lensesAgentAppendConf" -}}
{{- if .Values.lensesAgent.storage.postgres.enabled }}
lenses.storage.postgres.host={{ required "PostgreSQL 'host' value is mandatory" .Values.lensesAgent.storage.postgres.host | quote }}
lenses.storage.postgres.database={{ required "PostgreSQL 'database' value is mandatory" .Values.lensesAgent.storage.postgres.database | quote }}
{{- if not (eq (default "not-external" .Values.lensesAgent.storage.postgres.username) "external") }}
lenses.storage.postgres.username={{ required "PostgreSQL 'username' value is mandatory" .Values.lensesAgent.storage.postgres.username | quote }}
{{- end }}
{{- if and .Values.lensesAgent.storage.postgres.enabled .Values.lensesAgent.storage.postgres.password }}
{{- if not (eq (default "not-external" .Values.lensesAgent.storage.postgres.password) "external") }}
lenses.storage.postgres.password={{ required "PostgreSQL 'password' value is mandatory" .Values.lensesAgent.storage.postgres.password | quote }}
{{- end -}}
{{- end -}}
{{- if .Values.lensesAgent.storage.postgres.port }}
lenses.storage.postgres.port={{  .Values.lensesAgent.storage.postgres.port | quote }}
{{- end }}
{{- if .Values.lensesAgent.storage.postgres.schema }}
lenses.storage.postgres.schema={{ .Values.lensesAgent.storage.postgres.schema | quote }}
{{- end }}
{{- end }}
lenses.provisioning.path={{ required "Provisioning 'path' value is mandatory" .Values.lensesAgent.provision.path | quote }}
{{- if .Values.lensesAgent.provision.interval }}
lenses.provisioning.interval={{ .Values.lensesAgent.provision.interval }}
{{- end }}
{{ default "" .Values.lensesAgent.append.conf }}
{{- end -}}

{{- define "lensesOpts" -}}
{{- if .Values.lensesAgent.opts.keyStoreFileData }}-Djavax.net.ssl.keyStore="/mnt/secrets/lenses.opts.keystore.jks" {{ end -}}
{{- if .Values.lensesAgent.opts.keyStorePassword }}-Djavax.net.ssl.keyStorePassword="${CLIENT_OPTS_KEYSTORE_PASSWORD}" {{ end -}}
{{- if .Values.lensesAgent.opts.trustStoreFileData }}-Djavax.net.ssl.trustStore="/mnt/secrets/lenses.opts.truststore.jks" {{ end -}}
{{- if .Values.lensesAgent.opts.trustStorePassword }}-Djavax.net.ssl.trustStorePassword="${CLIENT_OPTS_TRUSTSTORE_PASSWORD}" {{ end -}}
{{- if .Values.lensesAgent.lensesOpts }}{{- .Values.lensesAgent.lensesOpts }}{{- end -}}
{{- end -}}

{{- define "lensesLogBackOpts" -}}
{{- if .Values.lensesAgent.logbackXml }}-Dlogback.configurationFile="file:{{ .Values.lensesAgent.logbackXml}}" {{ end -}}
{{- if .Values.lensesAgent.jvm.logBackOpts }}{{- .Values.lensesAgent.jvm.logBackOpts }}{{- end -}}
{{- end -}}

{{- define "agentKeySecretName" -}}
{{- if .Values.nameOverride }}
  {{- printf "%s-%s" .Values.nameOverride "agentkey-secret" | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- printf "%s-%s" .Release.Name "agentkey-secret" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
