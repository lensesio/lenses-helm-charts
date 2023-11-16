# Helm Charts for Lenses, Lenses SQL Runners and Apache Kafka Connect and other components

This repo contains Helm Charts Apache Kafka components

Add the repo:

```bash
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update
```

## Lenses

Documentation for the Lenses chart can be found [here](https://docs.lenses.io/install_setup/deployment-options/kubernetes-deployment.html).

### FOR BASE64 encoding

Make sure to ***not*** include split lines.

```openssl base64 < client.keystore.jks | tr -d '\n' ```

# Building/Testing

Run ``_cicd/functions.sh package_all`` this in turn calls ``scripts/lint.sh`` which will perform linting checks on the charts and also check we aren't going to overwrite existing charts.

If all is good, check in, tag and push the ```docs`` folder. These charts are hosted on the GitHub page.

For further details on how to run tests: [Testing](./charts/lenses/tests/README.md)

# Contribute

Contributions are welcome for any Kafka Connector or any other component that is useful for building Data Streaming pipelines

# Signing
For integrity, we sign the Helm Charts. For more information see this document https://helm.sh/docs/topics/provenance/.

The steps to do so are as follows:

* Create a GPG key, and follow the steps to create it noting the name of the key which is later used for signing the charts.
```
  gpg --full-generate-key
```
* then export the key
```
  gpg --export-secret-keys > key.gpg
```
* encrypt the key following the manual steps in this doc https://docs.travis-ci.com/user/encrypting-files/
```
  openssl aes-256-cbc -k "HELM_KEY_PASSPHRASE" -in key.gpg -out key.gpg.enc
```
* And commit the key.gpg.enc to Git.

The ```_cicd/functions.sh package_all``` then needs to be updated with the key name, and an environment variable ```HELM_KEY_PASSPHRASE```
created in the travis build settings with the pass phrase used to encrypt the key.
