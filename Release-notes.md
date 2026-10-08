# Release notes for Lenses Helm chart

## Release 5.5.25

Security hardening of the Kubernetes permissions the chart gives Lenses. **No action is
needed:** with unchanged values, Lenses keeps its ServiceAccount and cluster-wide access,
and only the unused permissions are removed. The new options below are opt-in.

### What changed

- **Only the permissions Lenses 5.5 uses.** The ClusterRole no longer grants `list` or
  `watch` on Secrets, write access to pods, or any access to services, ingresses,
  replicasets, statefulsets, persistent volumes or claims, and it can no longer create
  namespaces. See `rbacRules` in `templates/_helper.tpl` for the full list. Deploying,
  scaling, stopping and deleting SQL Processors and viewing their logs work as before.
- **New optional values:**
  - `serviceAccount.create`, `serviceAccount.name`, `serviceAccount.annotations` and
    `serviceAccount.automountToken`: give Lenses its own ServiceAccount. The old form
    `serviceAccount: <name>` still works.
  - `namespaceScope`: grant the permissions with a `Role` and `RoleBinding` per namespace
    instead of a `ClusterRole`.
  - `lenses.sql.namespaces`: the namespaces Lenses deploys SQL Processors to. In
    `KUBERNETES` mode the chart sets `lenses.kubernetes.namespaces` to this list.

If `lenses.sql.mode` is `IN_PROC` or `CONNECT` (the default is `IN_PROC`), Lenses makes no
Kubernetes API calls. You can set `rbacEnable: false` and `serviceAccount.automountToken:
false`.

### Recommended: a dedicated ServiceAccount and namespace scope

By default Lenses runs as the namespace's `default` ServiceAccount, so the permissions the
chart grants it also apply to every pod in that namespace that does not set its own
ServiceAccount. To restrict them to Lenses, and to the namespaces your SQL Processors use:

1. **Find the namespaces where your SQL Processors run:**

   ```bash
   kubectl get deployments -A -l lenses.io/lenses-user=Lenses \
     -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name
   ```

2. **Set the values**, listing every namespace from step 1 (they must already exist):

   ```yaml
   serviceAccount:
     create: true
   namespaceScope: true
   lenses:
     sql:
       namespaces: [lenses, lenses-processors]
   ```

   Lenses cannot manage processors in namespaces missing from the list. They keep
   running, but Lenses shows them as stopped, and deleting one in Lenses leaves its
   Deployment running. Adding the namespace to the list and upgrading again restores them.

3. **Move anything you attached to the `default` ServiceAccount.** If you added
   `imagePullSecrets` or cloud IAM annotations (EKS IRSA, GKE Workload Identity, Azure
   Workload Identity) to `default`, use `image.imagePullSecrets` and
   `serviceAccount.annotations` instead.

4. **If you manage RBAC yourself** (`rbacEnable: false`, with your own `Role`/`RoleBinding`
   as described in the Lenses 5.5 documentation), bind it to the new ServiceAccount, which
   is named after the release (e.g. `lenses`). A `lenses.kubernetes.namespaces` setting in
   `lenses.append.conf` is merged with the one the chart writes from `lenses.sql.namespaces`:
   its `incluster` list replaces the chart's, and any other clusters it lists are added. Keep
   the two in step, or move the list to `lenses.sql.namespaces`.

## Release 4.3.11

- `Values.lenses.jvm.trustStoreFileData` has been deprecated  in favor of `Values.lenses.opts.trustStoreFileData` since they were duplicates, please use the latter.
- `Values.lenses.jvm.trustStorePassword` has been deprecated  in favor of `Values.lenses.opts.trustStorePassword` since they were duplicates, please use the latter.

## Release 4.2.12

Previously, Connect URL was inferred from `protocol`, `host` and
`port`. With this new addition, user is now given the option to
construct it explicitly using the newly introduced `url`  key which
precedes `host` (marked for deprecation in next major release). This
allows for adding custom paths e.g. `https://connect-worker-1:8083/custom/path`.

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
