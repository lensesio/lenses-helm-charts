#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

cloneSite() {
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

# Run the function at $1, pass the rest of the args
$1 "${@:2}"
