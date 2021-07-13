#!/usr/bin/env groovy

pipeline {

    agent {
        label 'docker&&ephemeral'
    }

    libraries {
        lib('lenses-jenkins-pipeline')
    }

    options {
        ansiColor 'xterm'
        disableConcurrentBuilds()
        copyArtifactPermission('*')
        buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '10'))
        parallelsAlwaysFailFast()
        timeout(time: 10, unit: 'MINUTES')
    }

    environment {
        MODE = "${params.FORCE_DEPLOY_TO_PRODUCTION || "${env.BRANCH_NAME}" == 'master' ? 'release' : 'internal'}"
    }

    stages {
        stage('Build Helm Charts') {
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

                    docker.image("dtzar/helm-kubectl").inside {
                        sh("_cicd/functions.sh package_all")
                    }

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
                DOCKER_IMAGE = 'lenses-helm-chart-repo'
                ARTIFACTORY_URL = 'https://lenses.jfrog.io/artifactory/'
                ARTIFACTORY_API_KEY = credentials('artifactory-lenses-helm')
                SSH_HOST = credentials('ssh-host')
            }
            steps {
                script {
                    docker.image("docker.bintray.io/jfrog/jfrog-cli-go").inside {
                        sh("jfrog rt u build/*.tgz ${HELM_REPOSITORY} --url=${ARTIFACTORY_URL} --apikey=${ARTIFACTORY_API_KEY}")
                    }

                    sshagent (credentials: ['57dab1e7-d47f-4c57-8eef-c107c4bb707a']){
                        sh '_cicd/functions.sh clone_site'
                    }
                }
            }
            post {
                always {
                    jiraSendDeploymentInfo(
                        site: 'landoop.atlassian.net',
                        environmentId: "ans-ci-backend-eu-01.landoop.com.",
                        environmentName: 'helm.repo.lenses.io',
                        environmentType: 'production'
                    )
                }
            }
        }

        stage('Upload Helm Chart to private repo') {
            when {
                not { branch 'release/**' }
            }
            environment {
                HELM_REPOSITORY = 'lenses-private-helm-charts'
                ARTIFACTORY_URL = 'https://lenses.jfrog.io/artifactory/'
                ARTIFACTORY_API_KEY = credentials('artifactory-lenses-helm')
            }
            steps {
                script {
                    docker.image("docker.bintray.io/jfrog/jfrog-cli-go").inside {
                        sh("jfrog rt u build/*.tgz ${HELM_REPOSITORY} --url=${ARTIFACTORY_URL} --apikey=${ARTIFACTORY_API_KEY}")
                    }
                }
            }
        }

        stage('Build Helm repo Docker image') {
            environment {
                DOCKER_IMAGE = 'eu.gcr.io/lenses-ci/lenses-helm-chart-repo'
                HELM_REPO_URL = "${env.MODE == 'release' ? 'https://helm.repo.lenses.io' : 'https://helm.repo.staging.lenses.io'}"
            }
            agent {
                docker {
                    image 'google/cloud-sdk'
                    args '-e HOME=/tmp'
                    reuseNode true
                }
            }
            steps {
                script {
                    gcloud.withServiceAccount('lenses-ci') {
                        dir('_cicd/image') {
                            env.BUILD_INFO = """
GIT_COMMIT=${env.GIT_COMMIT}
GIT_BRANCH=${env.GIT_BRANCH}
"""
                            sh "gcloud builds submit . --config=cloudbuild.yaml --substitutions=_DOCKER_IMAGE='${env.DOCKER_IMAGE}:${env.GIT_COMMIT}',_HELM_REPO_URL='${env.HELM_REPO_URL},_BUILD_INFO=${env.BUILD_INFO}'"

                            jenkinsHelper.info("new docker image built and pushed, to use this image: `docker pull ${env.DOCKER_IMAGE}:${env.GIT_COMMIT}`")
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes staging cluster using ArgoCD') {
            when {
                not {
                    branch 'master'
                }
            }
            steps{
                script {
                    deliveryHelper.commitToState (
                        path: 'cluster/production-internal/lenses-helm-chart-repo',
                        file: 'values.yaml',
                        branch: 'main',
                        replaceStrategy: 'tag',
                        value: env.GIT_COMMIT
                    )
                }
            }
            post {
                success {
                    jiraSendDeploymentInfo(
                        site: 'landoop.atlassian.net',
                        environmentId: "production-internal",
                        environmentName: 'help.repo.staging.lenses.io',
                        environmentType: 'staging'
                    )
                }
            }
        }
    }

    post {
        always {
            cleanWs()
            script {
                env.JIRA_BRANCH = "${env.CHANGE_BRANCH ? "${env.CHANGE_BRANCH}" : "${env.BRANCH_NAME}"}"
                jiraSendBuildInfo(site: 'landoop.atlassian.net', branch: "${env.JIRA_BRANCH}")
            }
        }
        failure {
            script {
                slackHelper.jobStatus("#wh-sre")
            }
        }
    }
}
