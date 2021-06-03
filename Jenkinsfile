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
    environment {
        BRANCH_VERSION = env.BRANCH_NAME
            .trim()
            .toLowerCase()
            .replaceAll(' ','-')
            .replaceAll('/','-')
            .replaceAll('\\.','-')

        BUILD_MODE = "${env.BRANCH_NAME ==~ /^release\/[0-9]+\.[0-9]$/ ? 'release' : 'development'}"
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

        stage('Upload Helm Chart to public repo') {
            when {
                anyOf {
                    branch 'release/4.2'
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
            post {
                always {
                    jiraSendDeploymentInfo site: 'landoop.atlassian.net',
                        environmentId: "ans-ci-backend-eu-01.landoop.com.",
                        environmentName: 'helm.repo.lenses.io',
                        environmentType: 'production'
                }
            }
        }

        stage('Upload Helm Chart to private repo') {
            when {
                anyOf {
                    branch 'release/4.2'
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
            script {
                env.JIRA_BRANCH = "${env.CHANGE_BRANCH ? "${env.CHANGE_BRANCH}" : "${env.BRANCH_NAME}"}"
                jiraSendBuildInfo site: 'landoop.atlassian.net', branch: "${env.JIRA_BRANCH}"
            }
        }
        failure {
            script {
                if (env.BUILD_MODE == 'release') {
                    slackSend(
                        channel: "#dev-ops",
                            message: """
*:warning: :warning: ${currentBuild.currentResult} :warning: :warning:*

Failed build ${BUILD_ID} for commit `${CI_COMMIT_SHORT}` by <mailto:${CI_COMMIT_AUTHOR_EMAIL}|${CI_COMMIT_AUTHOR}>
from <${GIT_URL}|${GIT_URL[8..-5]}>, branch <${GIT_URL[0..-5]}/tree/${BRANCH_NAME}|${BRANCH_NAME}>.

• <${RUN_DISPLAY_URL}|Build log, Unit Tests Report, Artifacts>
""",
                        sendAsText: true
                    )
                }
            }
        }
    }
}
