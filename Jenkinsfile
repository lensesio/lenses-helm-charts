#!/usr/bin/env groovy

pipeline {

    agent {
        label 'docker && lightweight'
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
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }

    parameters {
        booleanParam(
            name: 'DEBUG_FLAG',
            defaultValue: false,
            description: 'Enable additional debug output'
        )
    }

    environment {
        // If this matches the branch name it will DEPLOY to PUBLIC HELM REPO
        RELEASE_BRANCH_FOR_PUBLIC = 'release/5.5'
    }

    stages {
        stage('Test & build Helm Charts') {
            agent {
                docker {
                    label 'docker && lightweight'
                    image env.HELM_WITH_TOOLS_DOCKER_IMAGE
                    args '-e HOME=/tmp'
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
                    env.RELEASE_PUBLIC = false
                    if (env.BRANCH_NAME =~ /^release/) {
                        env.BUILD_MODE = 'release'
                        if (env.BRANCH_NAME == env.RELEASE_BRANCH_FOR_PUBLIC) {
                            env.RELEASE_PUBLIC = true
                        }
                    }
                    jenkinsHelper.info("Build mode: ${env.BUILD_MODE}")
                    jenkinsHelper.info("Release public: ${env.RELEASE_PUBLIC}")

                    sh("_cicd/functions.sh setup_helm")
                    sh("_cicd/functions.sh package_all")

                    echo "==== Recording test results"
                    junit (
                        testResults: 'junit/*.xml',
                        allowEmptyResults: false
                    )

                    dir('build') {
                        archiveArtifacts '*.tgz'
                    }
                }
            }
        }

        stage('Upload Helm Chart to public JFrog repo') {
            when {
                environment name: 'RELEASE_PUBLIC', value: 'true'
            }
            environment {
                HELM_REPOSITORY = 'lenses-helm-charts'
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

        // We want all public images in private repo too
        stage('Upload Helm Chart to private JFrog repo') {
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

        stage('Pull Helm Chart repo and build static assets') {
            agent {
                docker {
                    label 'docker && lightweight'
                    image env.HELM_WITH_TOOLS_DOCKER_IMAGE
                    args '-e HOME=/tmp'
                    reuseNode true
                }
            }
            environment {
                SOURCE_HELM_REPO_URL = "${env.BUILD_MODE == 'release' ? 'https://lenses.jfrog.io/artifactory/helm-charts/' : 'https://lenses.jfrog.io/artifactory/lenses-private-helm-repo/'}"
                TARGET_HELM_REPO_URL = "${env.BUILD_MODE == 'release' ? 'https://helm.repo.lenses.io' : 'https://helm.repo.staging.lenses.io'}"
            }
            steps {
                script {
                    jenkinsHelper.info("Source helm repo url: ${env.SOURCE_HELM_REPO_URL}")
                    jenkinsHelper.info("Target helm repo url: ${env.TARGET_HELM_REPO_URL}")

                    // Delete old content
                    dir('_cicd/image/charts') { deleteDir() }

                    dir('_cicd/image/charts') {
                        withCredentials([
                            usernamePassword(
                                credentialsId: '9ab1ec30-daf0-4311-bc77-0e49cec71a42',
                                usernameVariable: 'ARTIFACTORY_USER',
                                passwordVariable: 'ARTIFACTORY_PASSWORD'
                            )
                        ]) {
                            // Build the static site by taking index.yaml/charts from jfrog and static index.html from Google bucket
                            sh "${WORKSPACE}/_cicd/functions.sh clone_site"
                        }
                        archiveArtifacts '*.yaml'
                    }
                }
            }
        }

        stage('Upload static assets to production Lenses website') {
            when {
                environment name: 'RELEASE_PUBLIC', value: 'true'
            }
            environment {
                SSH_HOST = credentials('ssh-host')
            }
            steps {
                script {
                    dir('_cicd/image/charts') {
                        // Upload the updated site to helm.repo.lenses.io
                        sshagent (credentials: ['57dab1e7-d47f-4c57-8eef-c107c4bb707a']) {
                            sh "${WORKSPACE}/_cicd/functions.sh upload_site"
                        }
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

        stage('Build Helm repo Docker image') {
            environment {
                DOCKER_IMAGE = 'eu.gcr.io/lenses-ci/lenses-helm-chart-repo'
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
                            sh "gcloud builds submit . --config=cloudbuild.yaml --substitutions=_DOCKER_IMAGE='${env.DOCKER_IMAGE}:${env.GIT_COMMIT}',_BUILD_INFO='${env.BUILD_INFO}'"
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
