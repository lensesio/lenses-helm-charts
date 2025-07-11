# lenses-agent

![Version: 6.0.3](https://img.shields.io/badge/Version-6.0.3-informational?style=flat-square) ![AppVersion: 6.0.3](https://img.shields.io/badge/AppVersion-6.0.3-informational?style=flat-square)

A chart for Lenses Agent deployment (ex. Lenses v5).

## Introduction

Lenses Agent is major upgrade of ex. Lenses v5 whose job is still

## Prerequisistes
- Kubernetes 1.23+
- Helm 3.8.0+
-  *External secret operator (in case of `ExternalSecret` usage)

## Installing the Chart
To install the chart with the release name `lenses-agent-release`:

```console
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update

helm install lenses-agent .  --namespace lenses-agent -f examples/values.yaml
```

> Note: You need to substitute the placeholder `.` with a reference to your Helm chart registry and repository. For example, in the case of ex-Lenses, you need to use lensesio/lenses

The command deploys Lenses Agent on the Kubernetes cluster in the example configuration. The Parameters section lists the parameters (#parameters) that can be configured during installation.

## Parameters

## Values

### Extras

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalVolumeMounts | list | `nil` | Additional volume mounts to use in Lenses delpoyments, for example to load additional plugins (UDFs) in Lenses Use it in conjuction with lenses.additionalVolumes |
| additionalVolumes | list | `nil` | Additional volumes to use in Lenses delpoyments either by Lenses for other sidecars like Lenses provisioner. |
| containerSecurityContext.readOnlyRootFilesystem | list | `false` | Enabling read only root filesystem. |
| lensesAgent.additionalEnv | string | `nil` | Additional env variables appended to deployment Follows the format of [EnvVar spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#envvar-v1-core) |
| lensesAgent.append.conf | string | `""` | Additional parameters which usually go to lenses.conf and are not supported by this Helm Chart. |
| lensesAgent.grafanaUrl | string | `nil` | URL for Grafana UI |
| lensesAgent.lensesOpts | string | `""` | For additional generic JVM settings |
| lensesAgent.livenessProbe.enabled | string | `true` | Disables livenessProbe, used while debugging |
| lensesAgent.pauseExec.enabled | string | `false` | Pauses execution of Lenses start up script to allow the user to login into the container and check the running environment, used while debugging |
| lensesAgent.topics.suffix | string | `nil` | Suffix to add to lenses system topics, for example if you are running more than one Lenses on the same kafka cluster |

### Custom deployment values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | dict | `{}` | Deployment affinity rules |
| annotations | dict | `{}` | Custom deployment annotations |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"lensesio/lenses-agent"}` | Image map |
| image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy |
| image.repository | string | `"lensesio/lenses-agent"` | Image repository |
| labels | dict | `{}` | Deployment labels |
| nodeSelector | dict | `{}` | Deployment nodeSelector |
| podTemplateAnnotations | dict | `{}` | Annotations here go into the PodTemplateSpec at deployment.spec.template.annotations. |
| resources | object | `{"limits":{"memory":"5Gi"},"requests":{"memory":"4Gi"}}` | Pod resources |
| securityContext | dict | `{}` | Deployment security context |
| strategy | dict | `{}` | Deployment strategy |
| tolerations | dict | `{}` | Deployment tolerations |

### Agent <-> HQ scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesAgent.hq.agentKey.secret.externalSecret.additionalSpecs | string | `{}` | Additional specifications that would enhance `spec:` of created ExternalSecret |
| lensesAgent.hq.agentKey.secret.externalSecret.secretStoreRef.name | string | `""` | Name of cluster secret store created by ESO. |
| lensesAgent.hq.agentKey.secret.externalSecret.secretStoreRef.type | string | `""` | Type of secret store created by ESO. |
| lensesAgent.hq.agentKey.secret.type | string | `""` | Secret type for referencing / creating agent key Possible values: createNew | precreated | externalSecret |

### Agent JVM scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesAgent.jvm.heapOpts | string | `nil` | heapOpts are any overrides for Lenses Heap JVM options. Please adjust this in sync with 'resources.limits.memory' |
| lensesAgent.jvm.logBackOpts | string | `nil` | logBackOpts are any logging options. Lenses is using the logback library. |
| lensesAgent.jvm.performanceOpts | string | `nil` | performanceOpts are any jvm tuning options to add to the jvm |
| lensesAgent.opts | string | `{"trustStoreFileData":"","trustStorePassword":""}` | Global truststore/keystore for the JVM. base64 encoded truststore data openssl base64 < kafka.truststore.jks | tr -d '\n' |

### Agent Provision scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesAgent.provision.path | string | `"/mnt/provision-secrets"` | Path where provisioner will be initiated. |
| lensesAgent.provision.secrets | dict | `{}` | Secrets base64 encoded (such as keystores) which will be placed within provisioner folder upon initialisation. |

### Agent SQL Processor scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesAgent.sql.heap | string | `"1024M"` | Setting heap for each individual SQL Processor |
| lensesAgent.sql.livenessInitialDelay | string | `"60 seconds"` | Setting initial delay when SQL processor is being started |
| lensesAgent.sql.memLimit | string | `"1152M"` | Setting memory limit for each individual SQL Processor |
| lensesAgent.sql.memRequest | string | `"128M"` | Setting memory limit for each individual SQL Processor |
| lensesAgent.sql.minHeap | string | `"128M"` | Setting min heap for each individual SQL Processor |
| lensesAgent.sql.mode | string | `"IN_PROC"` | Setting execution mode for SQL Processors Example: IN_PROC | KUBERNETES |

### Agent Database scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lensesAgent.storage.postgres | dict | `{"database":null,"enabled":false,"host":null,"password":null,"port":null,"schema":null,"username":null}` | Connection details for Postgres database |
| lensesAgent.storage.postgres.database | string | `nil` | Postgres database name that Agent will connect to and communicate with. |
| lensesAgent.storage.postgres.enabled | boolean | `false` | Enables postgres database connection, otherwise H2 as internal database will be used. |
| lensesAgent.storage.postgres.host | string | `nil` | Postgres database host details |
| lensesAgent.storage.postgres.password | string | `nil` | Postgres user password details |
| lensesAgent.storage.postgres.port | int | `nil` | Postgres database port details |
| lensesAgent.storage.postgres.schema | string | `nil` | Postgres schema, defaults to public in case not defined. |
| lensesAgent.storage.postgres.username | string | `nil` | Postgres database user details |

### Monitoring scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| monitoring.enabled | dict | `true` | Enables port on certain port where path /metrics gets exposed. |
| monitoring.port | dict | `9102` | Sets port where metrics will be exposed |

### Permission scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| namespaceScope | bool | `true` | Enables namespaceScope which indicates that if the cluster has rbac and namespaceScope is enabled  role and role binding on namespace level will be created |
| rbacEnable | bool | `true` | Enables rbac which indicates if a the cluster has rbac enabled and a cluster role and clusterrolebinding should be created for the service account |
| serviceAccount | object | `{"annotations":{},"create":false,"name":"default"}` | User to be used by Lenses to deploy apps |
| serviceAccount.annotations | dict | `{}` | Additional service account annotations. |
| serviceAccount.create | bool | `false` | In case "true" new SA will be created with service.name as a SA name. |
| serviceAccount.name | string | `"default"` | Name of Service Account. In case serviceAccount.create is *false*, existing SA with defined name here will be used. |

### Persistence scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| persistence.log.accessModes | list | `["ReadWriteOnce"]` | Access mode rights for created persistence volumes. |
| persistence.log.annotations | boolean | `{}` | Annotations dedicated for logs. |
| persistence.log.enabled | boolean | `true` | Extra volume creation dedicated for logs. |
| persistence.log.size | string | `"5Gi"` | Size of persistence that will be created. |

### Lenses Agent deployment service values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| restPort | int | `3030` | Lenses Agent container port |
| service.annotations | dict | `{}` | Additional service annotations |
| service.enabled | bool | `true` | Deciding factor whether Lenses HQ service will be created and which type |
| servicePortName | string | `"lenses-agent"` | Lenses Agent service port name |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` |  |
| lensesAgent.hq.agentKey.secret.key | string | `""` |  |
| lensesAgent.hq.agentKey.secret.name | string | `""` |  |
| lensesAgent.provision.connections | string | `nil` |  |
| nameOverride | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
