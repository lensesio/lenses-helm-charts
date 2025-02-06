# lenses-hq

![Version: 6.0.0-alpha.20](https://img.shields.io/badge/Version-6.0.0--alpha.20-informational?style=flat-square) ![AppVersion: 6.0.0-alpha.20](https://img.shields.io/badge/AppVersion-6.0.0--alpha.20-informational?style=flat-square)

A chart for Lenses HQ deployment which provides a unified, streamlined view of the entire event infrastructure—whether on-premises or in the cloud—through a single, comprehensive interface.

## Introduction

In the past, Lenses v5 represented one UI per Kafka cluster which led to managing dozens of UI, user permissions per UI and many more.

With Panoptes, we shrunk Lenses to only one UI called Lenses HQ where all administrative work is being done. Lenses Agent still has to be deployed and connected to HQ in order to collect information from connections (Kafka / Schema Registry / Connect Clusters / SQL Processors). After logging-in to HQ, user has ability to view all its topics / write sql queries and many more across all clusters access has been given to under single pane of glass.

## Prerequisistes
- Kubernetes 1.23+
- SAML (SSO)
- Helm 3.8.0+
- Postgres database
-  *External secret operator (in case of `ExternalSecret` usage)

## Installing the Chart
To install the chart with the release name `lenses-hq-release`:

```console
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update

helm install lenses-hq .  --namespace lenses-hq -f examples/values.yaml
```

> Note: You need to substitute the placeholder `.` with a reference to your Helm chart registry and repository. For example, in the case of ex-Lenses, you need to use lensesio/lenses

The command deploys Lenses HQ on the Kubernetes cluster in the example configuration. The Parameters section lists the parameters (#parameters) that can be configured during installation.

## Parameters

## Values

### Custom deployment values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | dict | `{}` | Deployment affinity rules |
| annotations | dict | `{}` | Custom deployment annotations |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"lensting/lenses-hq"}` | Image map |
| image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy |
| image.repository | string | `"lensting/lenses-hq"` | Image repository |
| labels | dict | `{}` | Deployment labels |
| nodeSelector | dict | `{}` | Deployment nodeSelector |
| podTemplateAnnotations | dict | `{}` | Annotations here go into the PodTemplateSpec at deployment.spec.template.annotations. |
| resources | object | `{"limits":{"memory":"5Gi"},"requests":{"memory":"4Gi"}}` | Pod resources |
| securityContext | dict | `{}` | Deployment security context |
| strategy | dict | `{}` | Deployment strategy |
| tolerations | dict | `[]` | Deployment tolerations |

### Lenses HQ Agent Ingress deployment service values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress.agent.agentIngressConfig | string | `{}` | Object defines the Kubernetes Ingress resource for the agent, including the apiVersion, kind, metadata (e.g., name),  and spec with routing rules, host, HTTP paths, and the backend service details (name and port). |
| ingress.agent.enabled | bool | `false` | If true, Ingress will be created |

### Lenses HQ HTTP API deployment service values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress.http.annotations | dict | `{}` | Custom Ingress annotations |
| ingress.http.enabled | bool | `false` | If true, Ingress will be created |
| ingress.http.host | tpl/string |  | Set custom host name. (DNS name convention) |
| ingress.http.tls | object | `{"enabled":false,"secretName":""}` | TLS if enabled load the tls.crt and tls.keys as a secrets and enable TLS on the ingress |
| ingress.http.tls.enabled | bool | `false` | Set to true to enable HTTPS |
| ingress.http.tls.secretName | string | `""` | Secret name where tls certificates are being stored. The TLS secret must contain keys named tls.crt and tls.key that contain the certificate and private key to use for TLS. |

### Extras

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.additionalEnv | string | `[]` | Additional env variables appended to deployment Follows the format of [EnvVar spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#envvar-v1-core) |

### Lenses HQ Agent startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.agents.address | string | `":10000"` | Address wherefrom agent will be listening at. **Required: true** |
| lensesHq.agents.tls.cert.referenceFromSecret | string | `false` | Enables usage of secret for certificate. **Required: false** |
| lensesHq.agents.tls.cert.secretKeyName | string | `""` | Secret key where within a secret where certificate is sotred. **Required: false** |
| lensesHq.agents.tls.cert.secretName | string | `""` | Secret name where certificate is stored. **Required: false** |
| lensesHq.agents.tls.cert.stringData | string | `""` | Sets the PEM formatted public certificate. **Required: false** |
| lensesHq.agents.tls.enabled | string | `false` | Enables or disables TLS. **Required: true** |
| lensesHq.agents.tls.privateKey | string | `{"secret":{"key":"","name":""}}` | Sets the PEM formatted private key. **Required: false** |
| lensesHq.agents.tls.verboseLogs | string | `false` | Enabled verbose of TLS debug logs **Required: true** |

### Lenses HQ AUTH startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.auth.administrators | list | `[]` | Grants administrator rights to users. **Required: false** |
| lensesHq.auth.users | list | `[]` | Adds uses for password based auth **Required: false** |

### Lenses HQ SAML startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.auth.saml.authnRequestSignature.authnRequestSigningCert.referenceFromSecret | string | `false` | Enables usage of secret for certificate. **Required: false** |
| lensesHq.auth.saml.authnRequestSignature.authnRequestSigningCert.secretKeyName | string | `""` | Secret key where within a secret where certificate is sotred. **Required: false** |
| lensesHq.auth.saml.authnRequestSignature.authnRequestSigningCert.secretName | string | `""` | Secret name where certificate is stored. **Required: false** |
| lensesHq.auth.saml.authnRequestSignature.authnRequestSigningCert.stringData | string | `""` | Sets the PEM formatted public certificate. **Required: false** |
| lensesHq.auth.saml.authnRequestSignature.authnRequestSigningKey.secret | string | `{"key":"","name":""}` | Reference to precreated secret name and key. **Required: false** |
| lensesHq.auth.saml.authnRequestSignature.enabled | bool | `true` | Enabled setting signature certificate in case "Request Signature Verification" enabled on IdP side **Required: false** |
| lensesHq.auth.saml.baseURL | string | `""` | Defines base URL of Panoptes for IdP redirects. **Required: true** |
| lensesHq.auth.saml.enabled | bool | `false` | Enables SAML / SSO authentication **Required: true** |
| lensesHq.auth.saml.entityID | string | `""` | Defines the Entity ID. **Required: true** |
| lensesHq.auth.saml.groupAttributeKey | string | `"groups"` | Sets the attribute name for group names. **Required: false** |
| lensesHq.auth.saml.metadata | object | `{"referenceFromSecret":false,"secretKeyName":"metadata.xml","secretName":"","stringData":""}` | Contains the IdP issued XML metadata blob. Example: <?xml version="1.0" ... (big blob of xml) </md:EntityDescriptor> **Required: true** |
| lensesHq.auth.saml.metadata.referenceFromSecret | boolean | `false` | Enables use of configmap to refernence SAML metadata file. **Required: true** |
| lensesHq.auth.saml.metadata.secretKeyName | string | `"metadata.xml"` | ConfigMap key used to reference configmap metadata information. **Required: false** |
| lensesHq.auth.saml.metadata.secretName | string | `""` | ConfigMap name which contains metadata information. **Required: false** |
| lensesHq.auth.saml.metadata.stringData | string | `""` | Contains the IdP issued XML metadata blob. Example: <?xml version="1.0" ... (big blob of xml) </md:EntityDescriptor> **Required: true** |
| lensesHq.auth.saml.uiRootURL | string | `"/"` | Controls where to redirect to upon successful authentication. **Required: false** |
| lensesHq.auth.saml.userCreationMode | string | `"manual"` | Controls how the creation of users should be handled in relation to SSO information Allowed values are: sso | manual **Required: false** |
| lensesHq.auth.saml.usersGroupMembershipManagementMode | string | `"manual"` | Controls how the management of a user's group membership should be handled in relation to SSO information. Allowed values are: sso | manual **Required: false** |
| lensesHq.auth.sessionDuration | string | `"24h"` | # Sets the duration of a session. The duration is a string that follows the Go time.Duration format. Valid time units are "ns", "us" (or "µs"), "ms", "s", "m", "h". The duration is used to set the expiration time of the session cookie. **Required: false** |

### Lenses HQ HTTP startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.http.accessControlAllowCredentials | bool | `false` | Sets the value of the "Access-Control-Allow-Credentials" header. **Required: false** |
| lensesHq.http.accessControlAllowOrigin | string | `[]` | Sets the address the HTTP server listens at. **Required: false** |
| lensesHq.http.address | string | `":8080"` | Sets the address the HTTP servers listens at. **Required: true** |
| lensesHq.http.secureSessionCookies | bool | `true` | Sets the "Secure" attribute on session cookies. **Required: false** |
| lensesHq.http.tls.cert.referenceFromSecret | string | `false` | Enables usage of secret for certificate. **Required: false** |
| lensesHq.http.tls.cert.secretKeyName | string | `""` | Secret key where within a secret where certificate is sotred. **Required: false** |
| lensesHq.http.tls.cert.secretName | string | `""` | Secret name where certificate is stored. **Required: false** |
| lensesHq.http.tls.cert.stringData | string | `""` | Sets the PEM formatted public certificate. **Required: false** |
| lensesHq.http.tls.enabled | string | `false` | Enables or disables TLS. **Required: true** |
| lensesHq.http.tls.privateKey | string | `{"secret":{"key":"","name":""}}` | Sets the PEM formatted private key. **Required: false** |
| lensesHq.http.tls.verboseLogs | string | `false` | Enabled verbose of TLS debug logs **Required: true** |

### Lenses HQ license values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.license.acceptEULA | string | `false` | Boolean 'acceptEULA' marks the end-user license agreement (EULA) as accepted. You can find the EULA at: https://lenses.io/legals/eula. **Required: false** |
| lensesHq.license.referenceFromSecret | string | `false` | Enables usage of secret for license. **Required: false** |
| lensesHq.license.secretKeyName | string | `""` | Secret key where within a secret where license is sotred. **Required: false** |
| lensesHq.license.secretName | string | `""` | Secret name where license is stored. **Required: false** |
| lensesHq.license.stringData | string | `""` | Sets the license as a stirng. **Required: false** |

### Lenses HQ startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.livenessProbe.enabled | bool | `true` |  |
| lensesHq.livenessProbe.tls.enabled | bool | `false` | Enabling HTTPS forliveness probe. |

### Lenses HQ logger startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.logger.level | string | `"info"` | Controls the level of the logger Allowed values are: info | debug **Required: false** |
| lensesHq.logger.mode | string | `"text"` | Controls the format of the logger's output. Allowed values are: text | json **Required: true** |

### Lenses HQ metrics startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.metrics.prometheusAddress | string | `":9090"` | ets the address at which Prometheus metrics are served. If not set, it will default to `:9090`` **Required: false** |

### Lenses HQ Database startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.storage.postgres.database | string | `""` | Database name to which HQ will connect to and store required information. **Required: true** |
| lensesHq.storage.postgres.enabled | string | `true` | Enabling postgres engine. This flag is here as there might be support of multiple database engines in the future. **Required: true** |
| lensesHq.storage.postgres.host | string | `""` | Hostname of running database instance. **Required: true** |
| lensesHq.storage.postgres.params | string | `{}` | Contains connection string parameters as key/values pairs. It allows    fine-grained control of connection settings. The parameters can be found    here: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PARAMKEYWORDS **Required: false** |
| lensesHq.storage.postgres.passwordSecret | object | `{"externalSecret":{"additionalSpecs":{},"secretStoreRef":{"name":"","type":""}},"key":"","name":"","password":"","type":"precreated"}` | Definition of secret that has been precreated and has postgres database password |
| lensesHq.storage.postgres.passwordSecret.externalSecret.additionalSpecs | string | `{}` | Additional specifications that would enhance `spec:` of created ExternalSecret |
| lensesHq.storage.postgres.passwordSecret.externalSecret.secretStoreRef.name | string | `""` | Name of cluster secret store created by ESO. |
| lensesHq.storage.postgres.passwordSecret.externalSecret.secretStoreRef.type | string | `""` | Type of secret store created by ESO. |
| lensesHq.storage.postgres.passwordSecret.key | string | `""` | Secret key where password will be read from |
| lensesHq.storage.postgres.passwordSecret.name | string | `""` | Secret name where database password will be stored in case "createNew" or read from in case of "precreated" | "externalSecret". |
| lensesHq.storage.postgres.passwordSecret.password | string | `""` | Entry for a password in case of testing where type: "createNew", otherwise can be left out. *NOT FOR PRODUCTION USE!* |
| lensesHq.storage.postgres.passwordSecret.type | string | `"precreated"` | Possible options: precreated | createNew | externalSecret |
| lensesHq.storage.postgres.port | int | `5432` | Port of running postgress instance. Default is 5432. **Required: true** |
| lensesHq.storage.postgres.schema | string | `""` | Database schema to which HQ will connect to and store required information. **Required: true** |
| lensesHq.storage.postgres.tls | string | `false` | Enables TLS. In PostgreSQL connection string terms, setting TLS to        `false` corresponds to `sslmode=disable`; setting TLS to `true`        corresponds to `sslmode=verify-full`. For more fine-grained control,        specify `sslmode` in the params which takes precedence. **Required: true** |
| lensesHq.storage.postgres.useSecretForUsername.enabled | string | `false` | Whether username will be used within a secret or as a part of `username` value. **Required: true** |
| lensesHq.storage.postgres.useSecretForUsername.existingSecret | string | `{"key":"","name":""}` | Secret reference for database user. **Required: false** |
| lensesHq.storage.postgres.username | string | `""` | Username which will be used for connecting to database database. **Required: true** |

### Permission scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| namespaceScope | bool | `true` | In case rbac is enabled you can choose to enable creation on namespace scoped roles instead of cluster roles instead |
| rbacEnable | bool | `true` | rbacEnable indicates if a the cluster has rbac enabled and a cluster role  and rolebinding should be created for the service account |
| serviceAccount | object | `{"annotations":{},"create":false,"name":"default"}` | User to be used by Lenses to deploy apps |
| serviceAccount.annotations | dict | `{}` | Additional service account annotations. |
| serviceAccount.create | bool | `false` | In case "true" new SA will be created with service.name as a SA name. |
| serviceAccount.name | string | `"default"` | Name of Service Account. In case serviceAccount.create is *false*, existing SA with defined name here will be used. |

### Lenses HQ deployment service values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| service.annotations | dict | `{}` | Additional service annotations |
| service.enabled | bool | `true` | Deciding factor whether Lenses HQ service will be created and which type |
| service.externalTrafficPolicy | string | `nil` |  |
| service.type | string | `"ClusterIP"` | Type of service to be created. |
| servicePort | int | `80` | Lenses HQ service port, service targets restPort |
| servicePortName | string | `"lenses-hq"` | Lenses HQ service port name |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` |  |
| ingress.http.ingressClassName | string | `""` |  |
| nameOverride | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
