# lenses-hq

![Version: 6.2.5](https://img.shields.io/badge/Version-6.2.5-informational?style=flat-square) ![AppVersion: 6.2.5](https://img.shields.io/badge/AppVersion-6.2.5-informational?style=flat-square)

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

### Extras

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalContainerSpec | list | `nil` | # Optionally add arbitrary fields to the main container spec (e.g. tty, stdin, etc) |
| additionalPodSpec | list | `nil` | Optionally add arbitrary fields to the pod spec (e.g. priorityClassName, priority, etc) |
| additionalVolumeMounts | list | `nil` | Additional volume mounts to use in Lenses delpoyments, for example to load additional plugins (UDFs) in Lenses Use it in conjuction with lenses.additionalVolumes |
| additionalVolumes | list | `nil` | Additional volumes to use in Lenses delpoyments either by Lenses for other sidecars. |
| lensesHq.additionalEnv | string | `[]` | Additional env variables appended to deployment Follows the format of [EnvVar spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#envvar-v1-core) |

### Custom deployment values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | dict | `{}` | Deployment affinity rules |
| annotations | dict | `{}` | Custom deployment annotations |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"lensesio/lenses-hq"}` | Image map |
| image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy |
| image.repository | string | `"lensesio/lenses-hq"` | Image repository |
| labels | dict | `{}` | Deployment labels |
| nodeSelector | dict | `{}` | Deployment nodeSelector |
| podTemplateAnnotations | dict | `{}` | Annotations here go into the PodTemplateSpec at deployment.spec.template.annotations. |
| resources | object | `{"limits":{"memory":"4Gi"},"requests":{"memory":"2Gi"}}` | Pod resources |
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

### Lenses HQ Agent startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.agents.address | string | `":10000"` | Address wherefrom agent will be listening at. **Required: true** |
| lensesHq.agents.grpc | string | `{"apiMaxRecvMessageSize":33554432}` | Contains Agent gRPC configuration. **Required: false** |
| lensesHq.agents.grpc.apiMaxRecvMessageSize | string | `33554432` | Overrides the default maximum body size in bytes for proxied API responses. **Required: false** |
| lensesHq.agents.tls.cert.referenceFromSecret | string | `false` | Enables usage of secret for certificate. **Required: false** |
| lensesHq.agents.tls.cert.secretKeyName | string | `""` | Secret key where within a secret where certificate is stored. **Required: false** |
| lensesHq.agents.tls.cert.secretName | string | `""` | Secret name where certificate is stored. **Required: false** |
| lensesHq.agents.tls.cert.stringData | string | `""` | Sets the PEM formatted public certificate. **Required: false** |
| lensesHq.agents.tls.enabled | string | `false` | Enables or disables TLS. **Required: true** |
| lensesHq.agents.tls.privateKey | string | `{"secret":{"key":"","name":""}}` | Sets the PEM formatted private key. **Required: false** |
| lensesHq.agents.tls.verboseLogs | string | `false` | Enabled verbose of TLS debug logs **Required: true** |

### Lenses HQ AUTH startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.auth.administrators | list | `["admin"]` | Grants administrator rights to users. **Required: false** |
| lensesHq.auth.users | list | `[{"password":"$2a$10$DPQYpxj4Y2iTWeuF1n.ItewXnbYXh5/E9lQwDJ/cI/.gBboW2Hodm","username":"admin"}]` | Adds uses for password based auth **Required: false** |

### Lenses HQ OAuth2 startup values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesHq.auth.oauth2.authorizationServer | object | `{"dcr":false,"enabled":false,"grantLifetime":"2160h","issuerURL":"","requirePKCE":true,"unauthenticatedIntrospection":false}` | Controls HQ's OAuth2 embedded authorization server. Rendered into HQ's config only when `authorizationServer.enabled` is true. |
| lensesHq.auth.oauth2.authorizationServer.dcr | bool | `false` | Enables the dynamic client registration endpoint ([RFC 7591](https://datatracker.ietf.org/doc/html/rfc7591)). MUST be `true` when the MCP sidecar is enabled — MCP clients register themselves via DCR. **Required: false** |
| lensesHq.auth.oauth2.authorizationServer.enabled | bool | `false` | Enables HQ's embedded OAuth 2.1 authorization server. **Required: false** |
| lensesHq.auth.oauth2.authorizationServer.grantLifetime | string | `"2160h"` | Absolute maximum lifetime of an authorization grant (Go time.Duration format). Default 2160h (90 days). **Required: false** |
| lensesHq.auth.oauth2.authorizationServer.issuerURL | string | `""` | The OAuth 2.0 Authorization Server issuer identifier ([RFC 8414](https://datatracker.ietf.org/doc/html/rfc8414)). Must equal the URL that clients use to reach HQ and therefore **must match `mcp.lensesAdvertisedUrl`** when the MCP sidecar is enabled. **Required: true when enabled** |
| lensesHq.auth.oauth2.authorizationServer.requirePKCE | bool | `true` | Requires PKCE (S256) for all authorization requests. OAuth 2.1 mandates PKCE; leave enabled unless you know why you're disabling it. **Required: false** |
| lensesHq.auth.oauth2.authorizationServer.unauthenticatedIntrospection | bool | `false` | Allows unauthenticated requests to the `/oauth2/introspect` endpoint. MUST be `true` when the MCP sidecar is enabled, because MCP's `DiscoveryTokenVerifier` posts to the introspection endpoint without client credentials. Keep the HQ introspect endpoint cluster-internal — never expose it through a public ingress. **Required: false** |

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
| lensesHq.license.stringData | string | `"license_key_2SFZ0BesCNu6NFv0-EOSIvY22ChSzNWXa5nSds2l4z3y7aBgRPKCVnaeMlS57hHNVboR2kKaQ8Mtv1LFt0MPBBACGhDT5If8PmTraUM5xXLz4MYv"` | Sets the license as a string. Community license available as a default. **Required: false** |

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
| lensesHq.storage.postgres.passwordSecret | object | `{"externalSecret":{"additionalSpecs":{},"creationPolicy":"Owner","secretStoreRef":{"name":"","type":""}},"key":"","name":"","password":"","type":"precreated"}` | Definition of secret that has been precreated and has postgres database password |
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

### MCP sidecar values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| mcp.additionalEnv | list | `[]` | Additional env variables appended to the MCP sidecar container. Follows the format of [EnvVar spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#envvar-v1-core). Note: entries here are appended after the chart-managed env vars; setting a duplicate key (e.g. `LENSES_URL`, `TRANSPORT`, `LENSES_ADVERTISED_URL`, `MCP_ADVERTISED_URL`) is rejected by the Kubernetes API. |
| mcp.enabled | bool | `false` | Deploy the Lenses MCP Server (`lensesio/mcp`) as a sidecar container alongside HQ, with its own Service and optional Ingress. When enabled, the MCP container listens on pod port **8000** (image default, not configurable). |
| mcp.image | dict | `{"pullPolicy":"IfNotPresent","repository":"lensesio/mcp"}` | MCP sidecar container image. |
| mcp.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy. |
| mcp.image.repository | string | `"lensesio/mcp"` | Image repository. |
| mcp.ingress.annotations | dict | `{}` | Custom Ingress annotations. |
| mcp.ingress.enabled | bool | `false` | If true, an Ingress resource is created for the MCP service. |
| mcp.ingress.host | string | `""` | Set custom host name (DNS name convention). Should correspond to the host in `mcp.mcpAdvertisedUrl`. |
| mcp.ingress.ingressClassName | string | `""` | Ingress class name. |
| mcp.ingress.tls | object | `{"enabled":false,"secretName":""}` | TLS. When enabled, the Ingress terminates TLS using the referenced secret. |
| mcp.ingress.tls.enabled | bool | `false` | Set to true to enable HTTPS. |
| mcp.ingress.tls.secretName | string | `""` | Secret name where tls certificates are stored. The TLS secret must contain keys named `tls.crt` and `tls.key`. |
| mcp.lensesAdvertisedUrl | string | `""` | Public URL at which Lenses HQ is reachable by MCP clients — typically the HQ ingress URL, e.g. `https://hq.example.com`. Mapped to the MCP container env var `LENSES_ADVERTISED_URL`. When HQ's embedded OAuth 2.1 authorization server is used (`lensesHq.auth.oauth2.authorizationServer.enabled`), this URL **must** match `lensesHq.auth.oauth2.authorizationServer.issuerURL` — RFC 8414 requires the issuer identifier to be byte-identical to the URL clients dial. |
| mcp.livenessProbe | dict | `{"enabled":true}` | Liveness probe for the MCP sidecar. Uses a TCP socket check against the MCP port because the `lensesio/mcp` image does not expose a dedicated `/health` endpoint. |
| mcp.mcpAdvertisedUrl | string | `""` | Public URL at which the MCP server is reachable by MCP clients — typically the MCP ingress URL, e.g. `https://mcp.example.com`. Mapped to the MCP container env var `MCP_ADVERTISED_URL`. |
| mcp.readinessProbe | dict | `{"enabled":true}` | Readiness probe for the MCP sidecar. Required so the MCP Service does not route traffic until MCP is actually listening during pod startup. |
| mcp.resources | dict | `{"limits":{"memory":"512Mi"},"requests":{"memory":"256Mi"}}` | Resources for the MCP sidecar container. |
| mcp.service.annotations | dict | `{}` | Additional service annotations. |
| mcp.service.enabled | bool | `true` | Create a dedicated Kubernetes Service for the MCP sidecar. |
| mcp.service.port | int | `80` | Service port. Targets the fixed MCP container port `8000`. |
| mcp.service.type | string | `"ClusterIP"` | Type of service to be created. |

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
