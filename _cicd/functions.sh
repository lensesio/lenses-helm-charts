#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

cloneSite() {
    mkdir -p "${HOME}/.ssh"
    ssh-keyscan -t rsa ${SSH_HOST#*@} >> ~/.ssh/known_hosts

    scp "${WORKSPACE}/_site/index.html" ${SSH_HOST}:/mnt/persistent/helm.repo.lenses.io/
    cat <<EOF | ssh ${SSH_HOST}
rm -rf /mnt/persistent/helm.repo.lenses.io/lenses.jfrog.io
cd /mnt/persistent/helm.repo.lenses.io
wget -m https://lenses.jfrog.io/artifactory/helm-charts/
sed  's|https://lenses.jfrog.io/artifactory/helm-charts|https://helm.repo.lenses.io|' -i lenses.jfrog.io/artifactory/helm-charts/index.yaml
rm -f lenses.jfrog.io/artifactory/helm-charts/index.html
mv lenses.jfrog.io/artifactory/helm-charts/* .
rm -rf lenses.jfrog.io/
EOF
}

package_all() {
    mkdir -p "${SCRIPTS_DIR}/../build/"

    for CHART_DIR in "${SCRIPTS_DIR}/../charts"/*; do
        package "${CHART_DIR}"
    done

    ls -lsa "${SCRIPTS_DIR}/../build/"
}

package() {
    pushd "$1"
    if [[ "${BUILD_MODE}" == 'development' ]]; then
        set_development_chart_version
    fi
    helm lint .
    helm dep build .
    # TODO: sign package
    helm package -d "../../build" .
    popd
}

set_development_chart_version() {
    if [ ! -f ./Chart.yaml ]; then
        echo "=== Chart.yaml file in folder '$(pwd)' not found, exiting..."
        exit 1
    fi

    if [ -z "${BRANCH_VERSION}" ]; then
        echo "=== Env var BRANCH_VERSION not found, exiting..."
        exit 1
    fi

    # We keep major/minor and change patch to: `0-dev-[BRANCH_NAME]`
    sed -i '/^version/s/[^.]*$/'"0-dev-${BRANCH_VERSION}/" ./Chart.yaml
    echo "=== Chart.yaml file at $(pwd):"
    cat ./Chart.yaml
}

# Run the function at $1, pass the rest of the args
$1 "${@:2}"
