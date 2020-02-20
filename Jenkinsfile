#!/usr/bin/env groovy
node("nonSGX") {
    try {
        cleanWs()
        withCredentials([usernamePassword(credentialsId: 'SERVICE_PRINCIPAL_OSTCLAB',
                                          passwordVariable: 'SERVICE_PRINCIPAL_PASSWORD',
                                          usernameVariable: 'SERVICE_PRINCIPAL_ID'),
                         string(credentialsId: 'OSCTLabSubID', variable: 'SUBSCRIPTION_ID'),
                         string(credentialsId: 'TenantID', variable: 'TENANT_ID')]) {
            withEnv(["AZURE_CONFIG_DIR=${WORKSPACE}/gopath/src/github.com/Microsoft/oe-engine)",
                     "GOPATH=${WORKSPACE}/gopath",
                     "GOROOT=/usr/local/go",
                     "GOCACHE=${WORKSPACE}/gopath/.cache"]) {
                docker.withRegistry("https://oejenkinscidockerregistry.azurecr.io", "oejenkinscidockerregistry") {
                    def image = docker.image("oe-engine:latest")
                    image.pull()
                    image.inside('-e PATH=$PATH:/usr/local/go/bin:$WORKSPACE/gopath/bin') {
                        dir('gopath/src/github.com/Microsoft/oe-engine')  {
                            stage('Checkout') {
                                checkout scm
                            }
                            stage('Unit test') {
                                sh "echo \$PATH"
                            }
                            stage('Build') {
                                sh 'make build'
                            }
                            stage('Ubuntu 16.04') {
                                sh 'test/acc-pr-test.sh oe-ub1604.json'
                            }
                            stage('Ubuntu 18.04') {
                                sh 'test/acc-pr-test.sh oe-ub1804.json'
                            }
                            stage('Windows') {
                                sh 'test/acc-pr-test.sh oe-win.json'
                            }
                        }
                    }
                }
            }
        }
    } catch (err) {
        currentBuild.result = 'FAILURE'
        throw err
    } finally {
        archiveArtifacts artifacts: 'gopath/src/github.com/Microsoft/oe-engine/test/agent_logs/**/*.log', fingerprint: true, allowEmptyArchive: true
    }
}
