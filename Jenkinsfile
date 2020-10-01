#!/usr/bin/env groovy

pipeline {

    agent {
        label 'docker&&ephemeral'
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
            steps {
                script {
                    docker.image("dtzar/helm-kubectl").inside {
                        sh("./package.sh")
                    }
                    dir('build') {
                        archiveArtifacts '*.tgz'
                    }
                }
            }
        }
        stage('Upload Helm Chart to public repo') {
            when {
                branch 'release/**'
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

        stage('Upload Helm Chart to private repo') {
            when {
                not { branch 'release/**' }
                not { branch 'master' }
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

        stage('Update helm.repo.lenses.io') {
            when {
                branch 'release/**'
            }
            environment {
                SSH_HOST = credentials('ssh-host')
            }
            steps {
                sshagent (credentials: ['57dab1e7-d47f-4c57-8eef-c107c4bb707a']){
                    sh '_cicd/functions.sh cloneSite'
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
