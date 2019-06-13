#!/usr/bin/env groovy
node("nonSGX") {
    try {
        cleanWs()
        stage('build') {
            withCredentials([usernamePassword(credentialsId: 'SERVICE_PRINCIPAL_OSTCLAB',
                                              passwordVariable: 'SERVICE_PRINCIPAL_PASSWORD',
                                              usernameVariable: 'SERVICE_PRINCIPAL_ID')]) {
                withEnv(["GOPATH=${WORKSPACE}/gopath",
                         "GOROOT=/usr/local/go",
                         "GOCACHE=${WORKSPACE}/gopath/.cache"]) {
                    docker.withRegistry("https://oejenkinscidockerregistry.azurecr.io", "oejenkinscidockerregistry") {
                        def image = docker.image("oe-engine:latest")
                        image.pull()
                        image.inside('-e PATH=$PATH:/usr/local/go/bin:$WORKSPACE/gopath/bin') {
                            dir("gopath/src/github.com/Microsoft/oe-engine") {
                                checkout scm
                                sh 'make build'
                                sh 'rm -rf work'
                                sh 'mkdir work'
                                sh 'cp test/*.json work/'
                                sh 'cd work; AZURE_CONFIG_DIR=. OE_ENGINE_BIN=../bin/oe-engine ../test/acc-deploy-test.sh'
                            }
                        }
                    }
                }
            }
        }
    } catch (err) {
        echo err.getMessage
        currentBuild.result = 'FAILURE'
    } finally {
        archiveArtifacts artifacts: 'gopath/src/github.com/Microsoft/oe-engine/work/*.log', fingerprint: true, allowEmptyArchive: true
    }
}
