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

{{- define "claimName" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 57 | trimSuffix "-") "claim" -}}
{{- else -}}
{{- printf "%s-%s" (.Release.Name | trunc 57 | trimSuffix "-") "claim" -}}
{{- end -}}
{{- end -}}

{{- define "logsClaimName" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 57 | trimSuffix "-") "logsclaim" -}}
{{- else -}}
{{- printf "%s-%s" (.Release.Name | trunc 57 | trimSuffix "-") "logsclaim" -}}
{{- end -}}
{{- end -}}

{{- define "sidecarProvisionImage" -}}
{{- if .Values.lenses.provision.sidecar.image.tag -}}
{{- printf "%s:%s" .Values.lenses.provision.sidecar.image.repository .Values.lenses.provision.sidecar.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.lenses.provision.sidecar.image.repository (regexFind "\\d+\\.\\d+" .Chart.AppVersion) -}}
{{- end -}}
{{- end -}}

{{- define "lensesImage" -}}
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
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_metrics_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_metrics
{{- end -}}
{{- end -}}

{{- define "topologyTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
__topology_{{ .Values.lenses.topics.suffix }}
{{- else -}}
__topology
{{- end -}}
{{- end -}}

{{- define "externalMetricsTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
__topology__metrics_{{ .Values.lenses.topics.suffix }}
{{- else -}}
__topology__metrics
{{- end -}}
{{- end -}}

{{- define "kerberos" -}}
{{- if .Values.lenses.security.kerberos.enabled }}
lenses.security.kerberos.service.principal={{ .Values.lenses.security.kerberos.servicePrincipal | quote }}
lenses.security.kerberos.keytab=/mnt/secrets/lenses.keytab
lenses.security.kerberos.debug={{ .Values.lenses.security.kerberos.debug | quote }}
{{end -}}
{{- end -}}

{{- define "lensesAppendConf" -}}
{{- if .Values.lenses.storage.postgres.enabled }}
lenses.storage.postgres.host={{ required "PostgreSQL 'host' value is mandatory" .Values.lenses.storage.postgres.host | quote }}
lenses.storage.postgres.database={{ required "PostgreSQL 'database' value is mandatory" .Values.lenses.storage.postgres.database | quote }}
{{- if not (eq (default "not-external" .Values.lenses.storage.postgres.username) "external") }}
lenses.storage.postgres.username={{ required "PostgreSQL 'username' value is mandatory" .Values.lenses.storage.postgres.username | quote }}
{{- end }}
{{- if .Values.lenses.storage.postgres.port }}
lenses.storage.postgres.port={{  .Values.lenses.storage.postgres.port | quote }}
{{- end }}
{{- if .Values.lenses.storage.postgres.schema }}
lenses.storage.postgres.schema={{ .Values.lenses.storage.postgres.schema | quote }}
{{- end }}
{{- end }}
{{- if and .Values.lenses.provision.enabled (eq .Values.lenses.provision.version "2")}}
lenses.provisioning.path={{ required "Provisioning 'path' value is mandatory" .Values.lenses.provision.path | quote }}
{{- if .Values.lenses.provision.interval }}
lenses.provisioning.interval={{ .Values.lenses.provision.interval }}
{{- end }}
{{- end }}
{{- $sqlNamespaces := include "sqlNamespaces" . }}
{{- if and $sqlNamespaces (or (eq .Values.lenses.sql.mode "KUBERNETES") .Values.lenses.sql.namespaces) }}
lenses.kubernetes.namespaces {
  incluster = {{ splitList "," $sqlNamespaces | toJson }}
}
{{- end }}
{{ default "" .Values.lenses.append.conf }}
{{- end -}}

{{/*
ServiceAccount the Lenses pod runs as, and the only RBAC subject. Without a name it is
the release full name when the chart creates it, and `default` otherwise, as before 5.5.25.
Before chart 5.5.25 serviceAccount was a string naming an existing ServiceAccount (default
"default"). That form is still accepted, e.g. from `helm upgrade --reuse-values`, and
creates nothing.
*/}}
{{- define "serviceAccountName" -}}
{{- if kindIs "map" .Values.serviceAccount -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else if .Values.serviceAccount.create -}}
{{- include "fullname" . -}}
{{- else -}}
default
{{- end -}}
{{- else -}}
{{- default "default" .Values.serviceAccount -}}
{{- end -}}
{{- end -}}

{{- define "serviceAccountCreate" -}}
{{- if and (kindIs "map" .Values.serviceAccount) .Values.serviceAccount.create -}}
true
{{- end -}}
{{- end -}}

{{/*
Comma-separated namespaces Lenses can deploy SQL Processors to. Empty means all of them:
Lenses then lists namespaces and watches cluster-wide, which needs the ClusterRole. The
list is pinned in lenses.append.conf in KUBERNETES mode, or whenever it is set explicitly.
*/}}
{{- define "sqlNamespaces" -}}
{{- $namespaces := .Values.lenses.sql.namespaces | default list -}}
{{- if and (not $namespaces) .Values.rbacEnable .Values.namespaceScope -}}
{{- $namespaces = list .Release.Namespace -}}
{{- end -}}
{{- $namespaces | uniq | join "," -}}
{{- end -}}

{{/*
What Lenses 5.5 calls to run SQL Processors in KUBERNETES mode (lenses-core
flows-deployments, fabric8 4.13.3). The Role and ClusterRole add their own namespaces rule.
*/}}
{{- define "rbacRules" -}}
# Deploy (create), scale (get + patch), stop (delete) and status (watch).
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["create", "get", "patch", "delete", "watch"]
# fabric8 4.13.3 retries an apps/v1 request that returned 404 against extensions/v1beta1.
# Kubernetes 1.16+ does not serve that group, so this grants nothing, but without it the
# retry gets 403 instead of 404 and stopping a processor whose Deployment is gone fails.
- apiGroups: ["extensions"]
  resources: ["deployments"]
  verbs: ["create", "get", "patch", "delete"]
# Processor secrets: createOrReplace on deploy (create, or get + update), delete on stop.
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["create", "get", "update", "delete"]
# Processor status (watch) and logs (get).
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["watch"]
{{- end -}}

{{- define "securityConf" -}}
{{- if .Values.lenses.security.defaultUser }}
{{- if not (eq (default "not-external" .Values.lenses.security.defaultUser.username) "external") }}
lenses.security.user={{ required "'username' for Lenses defaultUser is mandatory if 'password' is set" .Values.lenses.security.defaultUser.username | quote }}
{{- end -}}
{{- if not (eq (default "not-external" .Values.lenses.security.defaultUser.password) "external") }}
lenses.security.password={{ required "'password' for Lenses defaultUser is mandatory if 'username' is set" .Values.lenses.security.defaultUser.password | quote }}
{{- end -}}
{{- end -}}
{{- if .Values.lenses.security.ldap.enabled }}
lenses.security.ldap.url={{ .Values.lenses.security.ldap.url | quote }}
lenses.security.ldap.base={{ .Values.lenses.security.ldap.base | quote }}
lenses.security.ldap.user={{ .Values.lenses.security.ldap.user | quote }}
{{- if not (eq (default "not-external" .Values.lenses.security.ldap.password) "external") }}
lenses.security.ldap.password={{ .Values.lenses.security.ldap.password | quote }}
{{- end }}
lenses.security.ldap.filter={{ .Values.lenses.security.ldap.filter | quote }}
lenses.security.ldap.plugin.class={{ .Values.lenses.security.ldap.plugin.class | quote }}
lenses.security.ldap.plugin.memberof.key={{ .Values.lenses.security.ldap.plugin.memberofKey | quote }}
lenses.security.ldap.plugin.group.extract.regex={{ .Values.lenses.security.ldap.plugin.groupExtractRegex | quote }}
lenses.security.ldap.plugin.person.name.key={{ .Values.lenses.security.ldap.plugin.personNameKey | quote }}
{{- end -}}
{{- if .Values.lenses.security.saml.enabled }}
lenses.security.saml.base.url={{ .Values.lenses.security.saml.baseUrl | quote }}
lenses.security.saml.idp.provider={{ .Values.lenses.security.saml.provider | quote }}
lenses.security.saml.idp.metadata.file="/mnt/secrets/saml.idp.xml"
{{- if eq .Values.lenses.security.saml.provider "generic"}}
lenses.security.saml.idp.groups.attribute = {{ required "A value for 'lenses.security.saml.idp.groupsAttribute' is required when provider is set to 'generic' even if the IdP does not send one" .Values.lenses.security.saml.idp.groupsAttribute | quote }}
{{- if .Values.lenses.security.saml.idp.usernameAttribute }}
lenses.security.saml.idp.usernameAttribute = {{ .Values.lenses.security.saml.idp.usernameAttribute | quote }}
{{- end }}
{{- end }}
{{- if .Values.lenses.security.saml.idp.session.lifetime.max }}
lenses.security.saml.idp.session.lifetime.max = {{ .Values.lenses.security.saml.idp.session.lifetime.max | quote }}
{{- end }}
lenses.security.saml.keystore.location="/mnt/secrets/saml.keystore.jks"
{{- if .Values.lenses.security.saml.keyStorePassword }}
lenses.security.saml.keystore.password={{ .Values.lenses.security.saml.keyStorePassword | quote }}
{{- end }}
{{- if .Values.lenses.security.saml.groups.enabled }}
lenses.security.saml.groups.plugin.class={{ .Values.lenses.security.saml.groups.plugin.class | quote }}
{{- end }}
{{- if .Values.lenses.security.saml.keyAlias }}
lenses.security.saml.key.alias={{ .Values.lenses.security.saml.keyAlias | quote }}
{{- end }}
{{- if .Values.lenses.security.saml.keyPassword}}
lenses.security.saml.key.password={{ .Values.lenses.security.saml.keyPassword | quote }}
{{- end }}
{{- end }}
{{- if .Values.lenses.security.kerberos.enabled -}}
{{ include "kerberos" .}}
{{- end -}}
{{- if and .Values.lenses.storage.postgres.enabled .Values.lenses.storage.postgres.password }}
{{- if not (eq (default "not-external" .Values.lenses.storage.postgres.password) "external") }}
lenses.storage.postgres.password={{ required "PostgreSQL 'password' value is mandatory" .Values.lenses.storage.postgres.password | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "lensesOpts" -}}
{{- if .Values.lenses.opts.keyStoreFileData }}-Djavax.net.ssl.keyStore="/mnt/secrets/lenses.opts.keystore.jks" {{ end -}}
{{- if .Values.lenses.opts.keyStorePassword }}-Djavax.net.ssl.keyStorePassword="${CLIENT_OPTS_KEYSTORE_PASSWORD}" {{ end -}}
{{- if .Values.lenses.opts.trustStoreFileData }}-Djavax.net.ssl.trustStore="/mnt/secrets/lenses.opts.truststore.jks" {{ end -}}
{{- if .Values.lenses.opts.trustStorePassword }}-Djavax.net.ssl.trustStorePassword="${CLIENT_OPTS_TRUSTSTORE_PASSWORD}" {{ end -}}
{{- if .Values.lenses.lensesOpts }}{{- .Values.lenses.lensesOpts }}{{- end -}}
{{- end -}}

{{- define "lensesLogBackOpts" -}}
{{- if .Values.lenses.logbackXml }}-Dlogback.configurationFile="file:{{ .Values.lenses.logbackXml}}" {{ end -}}
{{- if .Values.lenses.jvm.logBackOpts }}{{- .Values.lenses.jvm.logBackOpts }}{{- end -}}
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
