# Release notes for Lenses Helm chart

## Release 4.1.0

### Breaking changes

- `schemaRegistries.enabled` is by default set to `false` so to activate Schema registry integration you need to explicitly enable it.
- `connectClusters.enabled` is by default set to `false` so to activate Connect clusters integration you need to explicitly enable it.

### Need manual action

There were changes in 'values.yaml' related to SASL to follow Lenses configuration changes on the same context.

- `jaasConfig` was introduced to set JAAS content inline instead of using a file, remember to not include `KafkaClient{}` wrapping
  ```yaml
  # values.yaml
  lenses:
    kafka:
      sasl:
        enabled: true
        jaasConfig: com.sun.security.auth.module.Krb5LoginModule required useKeyTab=true keyTab="lenses.keytab" storeKey=true useTicketCache=false serviceName=kafka principal="lenses@TESTING.LENSES.IO";
  ```
- `jaasFileData` was retained for backward compatibilty reasons but it is marked as deprecated and will be removed in future version.

### Additional configuration options suported

- `lenses.append.conf`, to set Lenses configuration values directly as text
  ```yaml
  # values.yaml
  lenses:
    append:
      conf:
  ```
- `security.append.conf`, to set Lenses security configuration values directly as text
  ```yaml
  # values.yaml
  lenses:
    security:
      append:
        conf:
  ```
- `LENSES_OPTS` enviromental variable for JVM generic settings
  ```yaml
  # values.yaml
  lenses:
    lensesOpts: |-
  ```
- Service provider plugin used in Kafka Connect connect
  ```yaml
  # values.yaml
  lenses:
    connectClusters:
      clusters:
        - aes256
          - key: CHANGEME
  ```
- Postgres, to use it as Lenses persistent storage
  ```yaml
  # values.yaml
  lenses:
    storage:
      postgres:
        enabled: false
        host:
        port:               # optional, defaults to 5432
        username:
        password:
        database:
        schema:             # optional, defaults to public schema
  ```
- Data Application Deployment Framework
  ```yaml
  # values.yaml
  lenses:
    deployments:
      eventsBufferSize: 10000
      errorsBufferSize: 1000

      connect:
        statusInterval: 30 second
        actionsBufferSize: 1000
  ```
- Sidecar containers, to run one or multiple sidecar containers alongside Lenses. It can be used to dynamically configure Lenses, do healthchecks or extract data from Lenses.
  ```yaml
  # values.yaml
  sidecarContainers:
    # - name: sidecar-example
    #   image: alpine
    #   command: ["sh", "-c", "watch datetime"]
  ```
-  Lenses sql, for finetuning
  ```yaml
  # values.yaml
  lenses:
    sql:
      minHeap: 128M
      livenessInitialDelay: 60 seconds
  ```
- Deployments, for finetuning
  ```yaml
  # values.yaml
  labels:
  annotations:
  strategy:
  nodeSlector:
  affinity:
  tolerations:
  ```
