#!/usr/bin/env groovy

pipeline {

    agent {
        label 'connector||docker'
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
        stage('Upload Helm Charts') {
            when {
                branch 'release/**'
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
    }

    post {
        always {
            cleanWs()
        }
    }
}
