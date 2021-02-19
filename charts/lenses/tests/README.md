# Helm unittests

> Repo: [lrills/helm-unittest](https://github.com/lrills/helm-unittest)

## Installation

```shell
helm plugin install https://github.com/lrills/helm-unittest
```

## Usage

Run the tests:

```shell
helm unittest -3 charts/lenses
# -3 enabled rendering using Helm3
```

## Write new or edit the tests

> [Test syntax](https://github.com/quintush/helm-unittest/blob/master/DOCUMENT.md)

- Create a new yaml file in `charts/lenses/tests` if needed. The filename has the following format:

```shell
[RESOURCE TARGET].[SCENARIO].run_test.yaml
```

- Re-run the tests

### Tips

## When `matchSnapshot` fails

Snapshot match takes a snapshot the current run and compares with the latest one. When it fails, it means that a change that is not explicitly tested has been found. If this happens follow the steps:

- Review the changes in the failed test
- Write tests that cover this change (optional but highly recommended)
- Run `helm unittest -3 -u charts/lenses` to update the snapshot manifest
- Commit the changes

## When you move tests between branches or update Helm chart version

You get a lot of failures in manifests due to the changed versions.
You have to run:

```
helm unittest -3 charts/lenses -u
```

manually to update these versions in manifests.
