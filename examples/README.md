# Helm Chart Examples

This directory includes examples of how to configure the Lenses' Helm chart
values for various scenarios. We break each configuration into a different yaml
file to make it easier to find the part you need and allow you to mix and match
configurations.

Configurations always start with `values.basic.yaml` which sets the
ingress. Without any other option set, the *basic* configuration will deploy
Lenses and bring you in the wizard mode, where you can configure your Kafka
Cluster following the steps in your browser.

Adding more value files, you can setup your Kafka Cluster and other connections
via the Helm Chart, enable single-sign-on via SAML, use PostreSQL as the backing
store for Lenses, and more.

Please note that in order to run Lenses you need a license. You can grab a trial
license from our [website](https://lenses.io/start/).

## Basic chart to deploy Lenses with Setup Wizard

This is the most basic chart, where Lenses is deployed with the default values:
- We use the on-disk database (H2)
- We create an ingress so we can access the Lenses web interface
- We will be greeted by the wizard, so we can setup the connection to the Kafka
  Brokers and add the license following the instructions on our browser.

To use it, you can edit `values.basic.yaml` to define your ingress host, then run:

```
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update
helm install --namespace lenses lenses lensesio/lenses \
     --values values.basic.yaml
```

*Tip:* it is also a good idea to change the default password of the
administrator user in this YAML file.

## Add (provision) a Kafka cluster

If you prefer to manage your connection(s) in the Helm chart rather than the web
interface, you can use the provisioning section of the charts.

There are multiple examples provided for various authentication scenarios.

### PLAINTEXT

Edit `values.provision.kafka.plaintext`, replace the sample bootstrap brokers
URLs with your own, and add any metrics settings if required. Then run:

```
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update
helm install --namespace lenses lenses lensesio/lenses \
     --values values.basic.yaml \
     --values values.provision.kafka.plaintext.yaml
```

### SSL

```
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update
helm install --namespace lenses lenses lensesio/lenses \
     --values values.basic.yaml \
     --values values.provision.kafka.ssl.yaml
```

### SASL_SSL with SCRAM512

TODO

### SASL_SSL with AWS IAM

TODO

## Add a license

If you have added a Kafka cluster connection to your chart, you can also add
your Lenses license if desired.

Edit `values.provision.license.yaml` and replace the sample license with your
own, then run:


```
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update
helm install --namespace lenses lenses lensesio/lenses \
     --values values.basic.yaml \
     --values values.provision.kafka.plaintext.yaml \
     --values values.provision.license.yaml
```

## Add a Schema Registry

### Confluent without authentication

Edit `values.provision.schema-registry.confluent.yaml`, replace the schema
registry URLs with your own, and add any metrics settings if required. You can
install the Lenses chart or upgrade if Lenses is already deployed and you just
added the Schema Registry connection:

```
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update
helm install --namespace lenses lenses lensesio/lenses \
     --values values.basic.yaml \
     --values values.provision.kafka.plaintext.yaml \
     --values values.provision.license.yaml \
     --values values.provision.schema-registry.confluent.yaml
```

### AWS Glue

TODO

## Add Kafka Connect clusters

Edit `values.provision.connect.yaml`, replace the Connect workers URLs with your
own, and add any metrics settings if required. You can install the Lenses chart
or upgrade if Lenses is already deployed and you just added or altered the
Connect connection(s):

```
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update
helm install --namespace lenses lenses lensesio/lenses \
     --values values.basic.yaml \
     --values values.provision.kafka.plaintext.yaml \
     --values values.provision.license.yaml \
     --values values.provision.schema-registry.confluent.yaml \
     --values values.provision.connect.yaml
```

### Connect with authentication

TODO

## Add other types of Connections

TODO

## Use PostgreSQL for the Lenses internal database

TODO

## Setup SAML authentication

TODO

## Setup LDAP/AD authentication

TODO

## Increase resources, memory and CPU

TODO

## Setup a custom truststore

TODO
