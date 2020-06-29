#!/usr/bin/env bash
set -o errexit
set -o pipefail

for CHART_DIR in charts/*; do
    helm lint "${CHART_DIR}"
    helm dep update "${CHART_DIR}"
    # TODO: sign package
    helm package -d ./build "${CHART_DIR}"
done
