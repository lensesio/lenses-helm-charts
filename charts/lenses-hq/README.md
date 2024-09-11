# lenses-hq

![Version: 6.0.0](https://img.shields.io/badge/Version-6.0.0-informational?style=flat-square) ![AppVersion: 6.0.0](https://img.shields.io/badge/AppVersion-6.0.0-informational?style=flat-square)

A chart for Lenses HQ

## TL;DR

```
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update

helm install lenses-hq .  --namespace lenses-hq -f examples/values.yaml
```

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
To install teh chart with the release name `lenses-hq-release`:

```console
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update

helm install lenses-hq .  --namespace lenses-hq -f examples/values.yaml
```

> Note: You need to substitute the placeholder `.` with a reference to your Helm chart registry and repository. For example, in the case of ex-Lenses, you need to use lensesio/lenses

The command deploys LensesHQ on the Kubernetes cluster in the example configuration. The Parameters section lists the parameters (#parameters) that can be configured during installation.

### Custom deployment values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | dict | `{}` | Deployment affinity rules |
| annotations | dict | `{}` | Custom deployment annotations |
| image | object | `{"pullPolicy":"IfNotPresent","repository":null}` | Image map |
| image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy |
| image.repository | string | `nil` | Image repository |
| labels | dict | `{}` | Deployment labels |
| nodeSelector | dict | `{}` | Deployment nodeSelector |
| podTemplateAnnotations | dict | `{}` | Annotations here go into the PodTemplateSpec at deployment.spec.template.annotations. |
| resources | object | `{"limits":{"memory":"5Gi"},"requests":{"memory":"4Gi"}}` | Pod resources |
| securityContext | dict | `{}` | Deployment security context |
| strategy | dict | `{}` | Deployment strategy |
| tolerations | dict | `{}` | Deployment tolerations |

### Lenses HQ deployment service values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress.annotations | dict | `{}` | Custom Ingress annotations |
| ingress.enabled | bool | `false` | If true, Ingress will be created |
| ingress.host | tpl/string | `nil` | Set custom host name. (DNS name convention) |
| ingress.tls | object | `{"crt":"","enabled":false,"key":""}` | TLS if enabled load the tls.crt and tls.keys as a secrets and enable TLS on the ingress |
| ingress.tls.enabled | bool | `false` | Set to true to enable HTTPS |
| restPort | int | `3030` | Lenses HQ container port |
| service.annotations | dict | `{}` | Additional service annotations |
| service.enabled | bool | `true` | Deciding factor whether Lenses HQ service will be created and which type |
| service.externalTrafficPolicy | string | `nil` |  |
| service.type | string | `"ClusterIP"` | Type of service to be created. |
| servicePort | int | `80` | Lenses HQ service port, service targets restPort |
| servicePortName | string | `"lenses-hq"` | Lenses HQ service port name |

### Lenses HQ startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.additionalEnv | map | `nil` | Additional env variables appended to deployment Follows the format of [EnvVar spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#envvar-v1-core) |
| lensesHq.agents.address | string | `":10000"` | Address wherefrom agent will be listening at. **Required: true** |
| lensesHq.agents.tls.cert | string | `""` | Sets the PEM formatted public certificate. **Required: false** |
| lensesHq.agents.tls.enabled | string | `false` | Enables or disables TLS. **Required: true** |
| lensesHq.agents.tls.privateKey | string | `{"secret":{"key":null,"name":null}}` | Sets the PEM formatted private key. **Required: false** |
| lensesHq.api.accessControlAllowCredentials | bool | `false` | Sets the value of the "Access-Control-Allow-Credentials" header. **Required: false** |
| lensesHq.api.accessControlAllowOrigin | string | `"[*]"` | Sets the address the HTTP server listens at. **Required: false** |
| lensesHq.api.address | string | `":8080"` | Sets the address the HTTP servers listens at. **Required: true** |
| lensesHq.api.administrators | list | `[]` | Grants administrator rights to users. **Required: false** |
| lensesHq.api.redirToIdp | boolean | `false` | Controls API HTTP behaviour on authentication errors. **Required: false** |
| lensesHq.api.saml.baseUrl | string | `""` | Defines base URL of Panoptes for IdP redirects. **Required: true** |
| lensesHq.api.saml.entityId | string | `""` | Defines the Entity ID. **Required: true** |
| lensesHq.api.saml.groupAttributeKey | string | `"group"` | Sets the attribute name for group names. **Required: false** |
| lensesHq.api.saml.metadata | string | `""` | Contains the IdP issued XML metadata blob. Example: <?xml version="1.0" ... (big blob of xml) </md:EntityDescriptor> **Required: true** |
| lensesHq.api.saml.organisationName | string | `""` | Sets the name of the organisation that users get assigned to. **Required: true** |
| lensesHq.api.saml.uiRootUrl | string | `"/"` | Controls where to redirect to upon successful authentication. **Required: false** |
| lensesHq.api.saml.userCreationMode | string | `"manual"` | Controls how the creation of users should be handled in relation to SSO information Allowed values are: sso | manual **Required: false** |
| lensesHq.api.saml.usersGroupMembershipManagementMode | string | `"manual"` | Controls how the management of a user's group membership should be handled in relation to SSO information. Allowed values are: sso | manual **Required: false** |
| lensesHq.api.secureSessionCookies | bool | `true` | Sets the "Secure" attribute on session cookies. **Required: false** |
| lensesHq.api.tls.cert | string | `""` | Sets the PEM formatted public certificate. **Required: false** |
| lensesHq.api.tls.enabled | string | `false` | Enables or disables TLS. **Required: true** |
| lensesHq.api.tls.privateKey | string | `{"secret":{"key":null,"name":null}}` | Sets the PEM formatted private key. **Required: false** |
| lensesHq.livenessProbe.enabled | bool | `true` |  |
| lensesHq.livenessProbe.tls.enabled | bool | `false` | Enabling HTTPS forliveness probe. |
| lensesHq.logger.level | string | `"info"` | Controls the level of the logger Allowed values are: info | debug **Required: false** |
| lensesHq.logger.mode | string | `"text"` | Controls the format of the logger's output. Allowed values are: text | json **Required: true** |
| lensesHq.metrics.prometheus_address | string | `":9090"` | ets the address at which Prometheus metrics are served. If not set, it will default to `:9090`` **Required: false** |
| lensesHq.monitoring | int | `{"port":9090}` | Port on which Lenses HQ will open for metric collection. |
| lensesHq.pauseExec | bool | `{"enabled":false}` | Execution postponment. Pause execution of Lenses HQ start up script to allow the user to login into the container and check the running environment, used while debugging |
| lensesHq.postgres.database | string | `nil` | Database name to which HQ will connect to and store required information. **Required: true** |
| lensesHq.postgres.passwordSecret | object | `{"externalSecret":{"secretStoreRef":{"clusterSecretStore":{"name":null}}},"key":null,"name":null,"password":null,"type":"precreated"}` | Definition of secret that has been precreated and has postgres database password |
| lensesHq.postgres.passwordSecret.externalSecret.secretStoreRef.clusterSecretStore.name | string | `nil` | Name of cluster secret store created by ESO. |
| lensesHq.postgres.passwordSecret.key | string | `nil` | Secret key where password will be read from |
| lensesHq.postgres.passwordSecret.name | string | `nil` | Secret name where database password will be stored in case "createNew" or read from in case of "precreated" | "externalSecret". |
| lensesHq.postgres.passwordSecret.password | string | `nil` | Entry for a password in case of testing where type: "createNew", otherwise can be left out. *NOT FOR PRODUCTION USE!* |
| lensesHq.postgres.passwordSecret.type | string | `"precreated"` | Possible options: precreated | createNew | externalSecret |
| lensesHq.postgres.port | int | `nil` | Port of running postgress instance. Default is 5432. **Required: true** |
| lensesHq.postgres.username | string | `nil` | Username which will be used for connecting to Postgres database. **Required: true** |

### Permission scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| namespaceScope | bool | `true` | In case rbac is enabled you can choose to enable namespace scoped roles or  cluster roles to be created |
| rbacEnable | bool | `true` | rbacEnable indicates if a the cluster has rbac enabled and a cluster role  and rolebinding should be created for the service account |
| serviceAccount | object | `{"annotations":{},"create":false,"name":"lenses"}` | User to be used by Lenses to deploy apps |
| serviceAccount.annotations | dict | `{}` | Additional service account annotations. |
| serviceAccount.create | bool | `false` | In case "true" new SA will be created with service.name as a SA name. |
| serviceAccount.name | string | `"lenses"` | Name of Service Account. In case serviceAccount.create is *false*, existing SA with defined name here will be used. |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` |  |
| lensesHq.postgres.host | string | `nil` |  |
| nameOverride | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
