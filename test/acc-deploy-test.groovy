pipeline {
  agent any
  stages {
	  stage('build') {
      agent {
        docker {
          image 'ubuntu18.04-dev'
          label 'nonSGX'
          args  '-e GOPATH=$WORKSPACE/gopath -e GOROOT=/usr/local/go -e PATH=$PATH:/usr/local/go/bin:$WORKSPACE/gopath/bin -e GOCACHE=$WORKSPACE/gopath/.cache'
        }
      }
      steps {
        dir("gopath/src/github.com/Microsoft/oe-engine") {
          git branch: 'master', url: 'https://github.com/Microsoft/oe-engine.git'
          sh 'make build'
          sh 'rm -rf work'
          sh 'mkdir work'
          sh 'cp test/*.json work/'
          withCredentials([usernamePassword(credentialsId: 'SERVICE_PRINCIPAL_OSTCLAB', passwordVariable: 'SERVICE_PRINCIPAL_PASSWORD', usernameVariable: 'SERVICE_PRINCIPAL_ID')]) {
            sh 'cd work; AZURE_CONFIG_DIR=. OE_ENGINE_BIN=../bin/oe-engine ../test/acc-deploy-test.sh'
          }
        }
      }
    }
  }
}
