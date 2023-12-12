# Helm Charts for Lenses

This repo contains the source code of the Lenses' Helm chart.

To use the chart, add Lenses' Helm repo:

```bash
helm repo add lensesio https://helm.repo.lenses.io/
helm repo update
```

And deploy Lenses, optionally setting your ingress:

```bash
helm install lenses lensesio/lenses \
  --namespace lenses \
  --set ingress.enabled=true \
  --set ingress.enabled.host=lenses.mycompany.url
```

To get started:
* For a complete reference of the values supported, have a look at the
  [values.yaml](./charts/lenses/values.yaml).
* Documentation for the chart can be found at our [documentation
 website](https://docs.lenses.io/5.4/installation/getting-started/helm/).
* Find many sample snippets for _values_ and how to combine them under the
  [examples directory](./examples).
