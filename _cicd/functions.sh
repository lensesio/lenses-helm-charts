#!/usr/bin/env bash

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

clone_site() {
    mkdir -p "${HOME}/.ssh"
    ssh-keyscan -t rsa ${SSH_HOST#*@} >> ~/.ssh/known_hosts

    cat <<EOF | ssh ${SSH_HOST}
rm -rf /mnt/persistent/helm.repo.lenses.io/lenses.jfrog.io
cd /mnt/persistent/helm.repo.lenses.io
wget -m https://lenses.jfrog.io/artifactory/helm-charts/
sed  's|https://lenses.jfrog.io/artifactory/helm-charts|https://helm.repo.lenses.io|' -i lenses.jfrog.io/artifactory/helm-charts/index.yaml
mv lenses.jfrog.io/artifactory/helm-charts/* .
rm -rf lenses.jfrog.io/ index.html
wget https://raw.githubusercontent.com/lensesio/kafka-helm-charts/gh-pages/index.html
EOF
}

setup_helm() {
    echo "=== Helm add plugins"
    eval "$(helm env)"
    helm plugin install https://github.com/quintush/helm-unittest --version master || true
    helm plugin ls
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
    if [ -f './.disable-package' ]; then
        echo "=== Packaging was disabled for chart $(basename ${PWD})"
        popd
        return
    fi

    run_tests

    echo -e "\n\n === Packaging $(basename ${PWD})"
    if [[ "${BUILD_MODE}" == 'development' ]]; then
        set_development_chart_version
    fi

    run_lint

    helm dep build .
    # TODO: sign package
    helm package -d "../../build" .

    if [[ "${BUILD_MODE}" == 'development' ]]; then
        # Restore version change after packaging
        git restore --source=HEAD --staged --worktree -- .
    fi
    popd
}

run_lint() {
    local extra_args=''

    if [ -f "./values.test.yaml" ]; then
        extra_args="${extra_args} -f ./values.test.yaml"
    fi

    helm lint . ${extra_args}
}

run_tests() {
    if [ -d "./tests" ]; then
        helm unittest -3 .
    fi
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

publish_all() {
    for CHART_DIR in "${SCRIPTS_DIR}/../build"/*.tgz; do
        jfrog rt u "${CHART_DIR}" ${HELM_REPOSITORY} --url=${ARTIFACTORY_URL} --apikey=${ARTIFACTORY_API_KEY}
    done
}

# Run the function at $1, pass the rest of the args
$1 "${@:2}"
