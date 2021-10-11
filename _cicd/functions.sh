#!/usr/bin/env bash

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

set -o errexit
set -o nounset
set -o pipefail
if [[ "${DEBUG_FLAG:-}" == "true" ]]; then
    set -o xtrace
fi

REPO_LABEL="ephemeral"

upload_site() {
    # local remote_path="/tmp/helm.repo.lenses.io"
    local remote_path="/mnt/persistent/helm.repo.lenses.io"

    mkdir -p "${HOME}/.ssh"
    ssh-keyscan -t rsa ${SSH_HOST#*@} >> ~/.ssh/known_hosts

    cat <<EOF | ssh ${SSH_HOST}
mkdir -p "${remote_path}"
EOF
    # Copy all files to proper path
    # TODO: Use rsync to update only the changed ones
    scp -r . "${SSH_HOST}:${remote_path}"
    cat <<EOF | ssh ${SSH_HOST}
ls -lsa "${remote_path}"
EOF
}

clone_site() {
    # Get index.yaml
    local add_args=""
    if [[ "${BUILD_MODE}" == 'development' ]]; then
        add_args="--username=${ARTIFACTORY_USER} --password=${ARTIFACTORY_PASSWORD}"
    fi
    # shellcheck disable=SC2086
    helm repo add "${REPO_LABEL}" "${SOURCE_HELM_REPO_URL}" ${add_args}
    helm repo update

    # Copy index.yaml
    eval "$(helm env)"
    cp "${HELM_CACHE_HOME}/repository/${REPO_LABEL}-index.yaml" index.yaml
    replace_in_index_yaml "https://lenses.jfrog.io/artifactory/api/helm/helm-charts"
    replace_in_index_yaml "https://lenses.jfrog.io/artifactory/api/helm/lenses-private-helm-repo"

    # Pull all charts // all versions
    pull_charts
    echo "=== Total files pulled: $(find .| wc -l)"
    if [[ "${DEBUG_FLAG:-}" == "true" ]]; then
        cat index.yaml
        ls -sla
    fi
}

pull_charts() {
    set +o xtrace
    local search_args=""
    if [[ "${BUILD_MODE}" == 'development' ]]; then
        search_args="--devel"
    fi
    CHARTS="$(helm search repo ${REPO_LABEL} ${search_args} | grep "${REPO_LABEL}/" | awk '{print $1}')"

    IFS=$'\n'
    for chart in $CHARTS; do
        pull_chart_versions "${chart}"
        # Use for testing
        # break
    done

    if [[ "${DEBUG_FLAG:-}" == "true" ]]; then
        set -o xtrace
    fi
}

pull_chart_versions() {
    local chart="${1}"
    local search_args=""
    if [[ "${BUILD_MODE}" == 'development' ]]; then
        search_args="--devel"
    fi
    CHART_VERSIONS="$(helm search repo "${chart}" --versions ${search_args} | grep "${REPO_LABEL}/" | awk '{print $2}')"

    IFS=$'\n'
    for version in $CHART_VERSIONS; do
        echo "Pulling ${chart}:${version}"
        helm pull "${chart}" --version "${version}" || echo "Pulling ${chart}:${version} FAILED!"
    done
}

replace_in_index_yaml() {
    set -o xtrace
    # TARGET_HELM_REPO_URL is different depending on if it is a release or not
    # and is populated in Jenkisfile
    sed "s|${1}|${TARGET_HELM_REPO_URL}|" -i index.yaml

    if [[ "${DEBUG_FLAG:-}" != "true" ]]; then
        set +o xtrace
    fi
}

setup_helm() {
    echo "=== Helm add plugins"
    eval "$(helm env)"
    helm plugin install https://github.com/quintush/helm-unittest --version master || true
    helm plugin ls
}

package_all() {
    mkdir -p "${WORKSPACE}/build/"
    mkdir -p "${WORKSPACE}/junit/"

    for CHART_DIR in "${SCRIPTS_DIR}/../charts"/*; do
        package "${CHART_DIR}"
    done

    ls -lsa "${WORKSPACE}/build/"
    ls -lsa "${WORKSPACE}/junit/"
}

package() {
    pushd "$1"

    local CHART_NAME
    CHART_NAME="$(basename ${PWD})"

    if [ -f './.disable-package' ]; then
        echo "=== Packaging was disabled for chart ${CHART_NAME}"
        popd
        return
    fi

    run_tests "${CHART_NAME}"

    echo -e "\n\n === Packaging ${CHART_NAME}"
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
    local CHART_NAME
    CHART_NAME="$1"

    if [ -d "./tests" ]; then
        helm unittest \
            -3 \
            --output-file "${WORKSPACE}/junit/junit-${CHART_NAME}.xml" \
            --output-type "JUnit" \
            .
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
    for CHART_DIR in "${WORKSPACE}/build"/*.tgz; do
        jfrog rt u "${CHART_DIR}" \
            "${HELM_REPOSITORY}" \
            --url="${ARTIFACTORY_URL}" \
            --apikey="${ARTIFACTORY_API_KEY}"
    done
}

# Run the function at $1, pass the rest of the args
$1 "${@:2}"
