# Release notes for Lenses Helm chart

## Release 4.2.9

This small feature adds the support for setting explicitly Connect metrics URL
whereas previously it was infered using Helm telmplating and certain
other keys. These keys ('metrics.type' and 'metrics.'port') are no
longer required and will be deprecated.

## Release 4.2.7

### Changes

- Sensitive values used in passwords while configuring Lenses can be taken from external Kubernetes resources using the underlying mechanism of transforming env vars to Lenses configuration. <br/> Supported sensitive values:
  - Schema registry Basic Auth username/password
  - Postgres username/password
  - Lenses default user username/password
  - License
  - Jaas config

### Deprecation notes

In version 5.0 we will stop supporting the following keys:

#### `lenses.env`

Currently used to inject custom env vars using key/value pairs:

```yaml
lenses:
  env:
    CUSTOM_ENV_VAR: "foo"
```

Should be migrated to:

```yaml
lenses:
  additionalEnv:
    - name: CUSTOM_ENV_VAR
      value: "foo"
```

#### `lenses.licenseUrl`

Currently used as a url pointing to the Lenses license:

```yaml
lenses:
  licenseUrl: example.com
```

Should be migrated to:

```yaml
lenses:
  additionalEnv:
    - name: LICENSE_URL
      value: "example.com"
```

#### `lenses.configOverrides`

Currently used as extra configurations that will be append to the `lenses.conf`:

```yaml
lenses:
  configOverrides:
    LENSES_PROPERTY: value
```

Should be migrated to:

```yaml
lenses:
  append:
    conf: |-
      lenses.property=value
```

## Release 4.2.0

### Changes

- `persistence.enabled` is by default set to `true`. Lenses is a stateful application and needs to store its state. By default we use sqlite which is saved in the mounted volume. If you use postgres as Lenses persistence layer, the mounted volume is still used for caching but its usage is optional and can be set to `false`.
- `replicas` is hardcoded to `1` until Lenses supports high availability (HA).
- Helm deploy command output, generated from `NOTES.txt`, reported a wrong url; it is now fixed.

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
