#!/usr/bin/env groovy

pipeline {

    agent {
        label 'docker && ephemeral'
    }

    options {
        ansiColor 'xterm'
        disableConcurrentBuilds()
        copyArtifactPermission('*')
        buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '10'))
        parallelsAlwaysFailFast()
        timeout(time: 10, unit: 'MINUTES')
    }

    stages {
        stage('Build Helm Charts') {
            agent {
                docker {
                    image "dtzar/helm-kubectl"
                    args '-e HOME=/tmp -e HELM_HOME=/tmp'
                    reuseNode true
                }
            }
            steps {
                script {

                    env.BRANCH_VERSION = env.BRANCH_NAME
                        .trim()
                        .toLowerCase()
                        .replaceAll(' ','-')
                        .replaceAll('/','-')
                        .replaceAll('\\.','-')

                    env.BUILD_MODE = 'development'
                    if (env.BRANCH_NAME =~ /^release/) {
                        env.BUILD_MODE = 'release'
                    }

                    sh("_cicd/functions.sh setup_helm")
                    sh("_cicd/functions.sh package_all")

                    dir('build') {
                        archiveArtifacts '*.tgz'
                    }
                }
            }
        }

        stage('Upload Helm Chart to public repo') {
            when {
                anyOf {
                    branch 'release/3.2'
                    branch 'release/4.0'
                }
            }
            environment {
                HELM_REPOSITORY = 'lenses-helm-charts'
                ARTIFACTORY_URL = 'https://lenses.jfrog.io/artifactory/'
                ARTIFACTORY_API_KEY = credentials('artifactory-lenses-helm')
                SSH_HOST = credentials('ssh-host')
            }
            steps {
                script {
                    docker.image("docker.bintray.io/jfrog/jfrog-cli-go").inside {
                        sh("jfrog rt u build/*.tgz ${HELM_REPOSITORY} --url=${ARTIFACTORY_URL} --apikey=${ARTIFACTORY_API_KEY}")
                    }

                    // Update helm.repo.lenses.io
                    sshagent (credentials: ['57dab1e7-d47f-4c57-8eef-c107c4bb707a']) {
                        sh '_cicd/functions.sh clone_site'
                    }
                }
            }
        }

        stage('Upload Helm Chart to private repo') {
            when {
                anyOf {
                    branch 'release/4.1'
                    not { branch 'release/**' }
                }
            }
            environment {
                HELM_REPOSITORY = 'lenses-private-helm-charts'
                ARTIFACTORY_URL = 'https://lenses.jfrog.io/artifactory/'
                ARTIFACTORY_API_KEY = credentials('artifactory-lenses-helm')
            }
            steps {
                script {
                    docker.image("docker.bintray.io/jfrog/jfrog-cli-go").inside {
                        sh("_cicd/functions.sh publish_all")
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
