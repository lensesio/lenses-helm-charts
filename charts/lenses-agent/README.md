# lenses-agent

![Version: 6.0.0](https://img.shields.io/badge/Version-6.0.0-informational?style=flat-square) ![AppVersion: 6.0.0](https://img.shields.io/badge/AppVersion-6.0.0-informational?style=flat-square)

A chart for Lenses Agent

### Permission scope values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| serviceAccount | object | `{"annotations":{},"create":false,"name":"default"}` | User to be used by Lenses to deploy apps |
| serviceAccount.annotations | dict | `{}` | Additional service account annotations. |
| serviceAccount.create | bool | `false` | In case "true" new SA will be created with service.name as a SA name. |
| serviceAccount.name | string | `"default"` | Name of Service Account. In case serviceAccount.create is *false*, existing SA with defined name here will be used. |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalVolumeMounts | string | `nil` |  |
| additionalVolumes | string | `nil` |  |
| affinity | object | `{}` |  |
| annotations | object | `{}` |  |
| containerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"lensesio/lenses"` |  |
| labels | object | `{}` |  |
| lenses.additionalEnv | string | `nil` |  |
| lenses.append.conf | string | `""` |  |
| lenses.deployments.connect.actionsBufferSize | int | `1000` |  |
| lenses.deployments.connect.statusInterval | string | `"30 second"` |  |
| lenses.deployments.errorsBufferSize | int | `1000` |  |
| lenses.deployments.eventsBufferSize | int | `10000` |  |
| lenses.grafanaUrl | string | `nil` |  |
| lenses.hq.agentKey.secret.externalSecret.secretStoreRef.clusterSecretStore.name | string | `"panoptes-secrets"` |  |
| lenses.hq.agentKey.secret.key | string | `"password"` |  |
| lenses.hq.agentKey.secret.name | string | `"lenses-hq-agent-secret"` |  |
| lenses.hq.agentKey.secret.type | string | `"externalSecret"` |  |
| lenses.hq.host | string | `"panoptes-backend.panoptes-master.svc.cluster.local"` |  |
| lenses.hq.port | int | `10000` |  |
| lenses.hq.ssl.enabled | bool | `false` |  |
| lenses.jvm.heapOpts | string | `nil` |  |
| lenses.jvm.logBackOpts | string | `nil` |  |
| lenses.jvm.performanceOpts | string | `nil` |  |
| lenses.lensesOpts | string | `""` |  |
| lenses.livenessProbe.enabled | bool | `true` |  |
| lenses.opts.trustStoreFileData | string | `""` |  |
| lenses.opts.trustStorePassword | string | `""` |  |
| lenses.pauseExec.enabled | bool | `false` |  |
| lenses.provision.enabled | bool | `false` |  |
| lenses.provision.path | string | `"/mnt/provision-secrets"` |  |
| lenses.provision.secrets | object | `{}` |  |
| lenses.provision.sidecar.additionalVolumeMounts | string | `nil` |  |
| lenses.provision.sidecar.image.repository | string | `"lensesio/lenses-cli"` |  |
| lenses.provision.version | string | `"2"` |  |
| lenses.sql.heap | string | `"1024M"` |  |
| lenses.sql.livenessInitialDelay | string | `"60 seconds"` |  |
| lenses.sql.memLimit | string | `"1152M"` |  |
| lenses.sql.memRequest | string | `"128M"` |  |
| lenses.sql.minHeap | string | `"128M"` |  |
| lenses.sql.mode | string | `"IN_PROC"` |  |
| lenses.storage.postgres.database | string | `nil` |  |
| lenses.storage.postgres.enabled | bool | `false` |  |
| lenses.storage.postgres.host | string | `nil` |  |
| lenses.storage.postgres.password | string | `nil` |  |
| lenses.storage.postgres.port | string | `nil` |  |
| lenses.storage.postgres.schema | string | `nil` |  |
| lenses.storage.postgres.username | string | `nil` |  |
| lenses.tls.clientAuth | bool | `false` |  |
| lenses.tls.enabled | bool | `false` |  |
| lenses.tls.keyPassword | string | `""` |  |
| lenses.tls.keyStoreFileData | string | `""` |  |
| lenses.tls.keyStorePassword | string | `""` |  |
| lenses.tls.trustStoreFileData | string | `""` |  |
| lenses.tls.trustStorePassword | string | `""` |  |
| lenses.topics.suffix | string | `nil` |  |
| monitoring.enabled | bool | `true` |  |
| monitoring.port | int | `9102` |  |
| nameOverride | string | `""` |  |
| namespaceScope | bool | `false` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.enabled | bool | `true` |  |
| persistence.log.enabled | bool | `true` |  |
| persistence.size | string | `"5Gi"` |  |
| podTemplateAnnotations | object | `{}` |  |
| rbacEnable | bool | `false` |  |
| resources.limits.memory | string | `"5Gi"` |  |
| resources.requests.memory | string | `"4Gi"` |  |
| restPort | int | `3030` |  |
| securityContext | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.externalTrafficPolicy | string | `nil` |  |
| service.type | string | `"ClusterIP"` |  |
| servicePort | int | `80` |  |
| servicePortName | string | `"lenses-agent"` |  |
| strategy | object | `{}` |  |
| tolerations | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
