# lenses-agent

![Version: 6.0.0-alpha.1](https://img.shields.io/badge/Version-6.0.0--alpha.1-informational?style=flat-square) ![AppVersion: v6.0.0-alpha.1-1-g2fad0a513](https://img.shields.io/badge/AppVersion-v6.0.0--alpha.1--1--g2fad0a513-informational?style=flat-square)

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
| lenses.additionalEnv | string | `nil` | Additional env variables appended to deployment Follows the format of [EnvVar spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#envvar-v1-core) |
| lenses.append.conf | string | `""` | Additional parameters which usually go to lenses.conf and are not supported by this Helm Chart. |
| lenses.grafanaUrl | string | `nil` | URL for Grafana UI |
| lenses.lensesOpts | string | `""` | For additional generic JVM settings |
| lenses.livenessProbe.enabled | string | `true` | Disables livenessProbe, used while debugging |
| lenses.pauseExec.enabled | string | `false` | Pauses execution of Lenses start up script to allow the user to login into the container and check the running environment, used while debugging |
| lenses.topics.suffix | string | `nil` | Suffix to add to lenses system topics, for example if you are running more than one Lenses on the same kafka cluster |

### Custom deployment values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | dict | `{}` | Deployment affinity rules |
| annotations | dict | `{}` | Custom deployment annotations |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"lensesio/lenses"}` | Image map |
| image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy |
| image.repository | string | `"lensesio/lenses"` | Image repository |
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
| lenses.hq.agentKey.secret.type | string | `""` | Secret type for referencing / creating agent key Possible values: createNew | precreated | externalSecret |

### Agent JVM scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lenses.jvm.heapOpts | string | `nil` | heapOpts are any overrides for Lenses Heap JVM options. Please adjust this in sync with 'resources.limits.memory' |
| lenses.jvm.logBackOpts | string | `nil` | logBackOpts are any logging options. Lenses is using the logback library. |
| lenses.jvm.performanceOpts | string | `nil` | performanceOpts are any jvm tuning options to add to the jvm |
| lenses.opts | string | `{"trustStoreFileData":"","trustStorePassword":""}` | Global truststore/keystore for the JVM. base64 encoded truststore data openssl base64 < kafka.truststore.jks | tr -d '\n' |

### Agent Provision scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lenses.provision.enabled | boolean | `true` | Enables provisioning to automate connections from Agent Possible values: createNew | precreated | externalSecret |
| lenses.provision.path | string | `"/mnt/provision-secrets"` | Path where provisioner will be initiated. |
| lenses.provision.secrets | dict | `{}` | Secrets base64 encoded (such as keystores) which will be placed within provisioner folder upon initialisation. |
| lenses.provision.version | string | `"2"` | Version of provisioning that will be used, currently only "2" is supported. Property is still here as a transition phase and will be removed in the future. |

### Agent SQL Processor scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lenses.sql.heap | string | `"1024M"` | Setting heap for each individual SQL Processor |
| lenses.sql.livenessInitialDelay | string | `"60 seconds"` | Setting initial delay when SQL processor is being started |
| lenses.sql.memLimit | string | `"1152M"` | Setting memory limit for each individual SQL Processor |
| lenses.sql.memRequest | string | `"128M"` | Setting memory limit for each individual SQL Processor |
| lenses.sql.minHeap | string | `"128M"` | Setting min heap for each individual SQL Processor |
| lenses.sql.mode | string | `"IN_PROC"` | Setting execution mode for SQL Processors Example: IN_PROC | KUBERNETES |

### Agent Database scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| lenses.storage.postgres | dict | `{"database":null,"enabled":false,"host":null,"password":null,"port":null,"schema":null,"username":null}` | Connection details for Postgres database |
| lenses.storage.postgres.database | string | `nil` | Postgres database name that Agent will connect to and communicate with. |
| lenses.storage.postgres.enabled | boolean | `false` | Enables postgres database connection, otherwise H2 as internal database will be used. |
| lenses.storage.postgres.host | string | `nil` | Postgres database host details |
| lenses.storage.postgres.password | string | `nil` | Postgres user password details |
| lenses.storage.postgres.port | int | `nil` | Postgres database port details |
| lenses.storage.postgres.schema | string | `nil` | Postgres schema, defaults to public in case not defined. |
| lenses.storage.postgres.username | string | `nil` | Postgres database user details |

### Monitoring scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| monitoring.enabled | dict | `true` | Enables port on certain port where path /metrics gets exposed. |
| monitoring.port | dict | `9102` | Sets port where metrics will be exposed |

### Permission scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| namespaceScope | bool | `false` | Enables namespaceScope which indicates that if the cluster has rbac and namespaceScope is enabled  role and role binding on namespace level will be created |
| rbacEnable | bool | `false` | Enables rbac which indicates if a the cluster has rbac enabled and a cluster role and clusterrolebinding should be created for the service account |
| serviceAccount | object | `{"annotations":{},"create":false,"name":"default"}` | User to be used by Lenses to deploy apps |
| serviceAccount.annotations | dict | `{}` | Additional service account annotations. |
| serviceAccount.create | bool | `false` | In case "true" new SA will be created with service.name as a SA name. |
| serviceAccount.name | string | `"default"` | Name of Service Account. In case serviceAccount.create is *false*, existing SA with defined name here will be used. |

### Persistence scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| persistence.accessModes | list | `["ReadWriteOnce"]` | Access mode rights for created persistence volumes. |
| persistence.enabled | boolean | `true` | If you use Data Policies module enable a Persistent Volume to keep your data policies rule. Also used when lenses.storage.enabled: false, and an H2 local filesystem database is used, instead of Postgresql. https://docs.lenses.io/current/installation/kubernetes/persistence/ |
| persistence.log.enabled | boolean | `true` | Extra volume creation dedicated for logs. |
| persistence.size | string | `"5Gi"` | Size of persistence that will be created. |

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
| lenses.hq.agentKey.secret.externalSecret.name | string | `""` |  |
| lenses.hq.agentKey.secret.externalSecret.secretStoreRef.clusterSecretStore.name | string | `""` |  |
| lenses.hq.agentKey.secret.key | string | `""` |  |
| lenses.hq.agentKey.secret.name | string | `""` |  |
| nameOverride | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
