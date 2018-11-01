pipeline {
  agent any
  environment {
    SUBSCRIPTION_ID = credentials('OSCTLabSubID')
    TENANT_ID = credentials('TenantID')
  }
  stages {
	stage('build') {
	  agent {
	    docker {
          image 'golang:1.11.0'
          label 'nonSGX'
          args  '-e GOPATH=$WORKSPACE/gopath -e PATH=$PATH:/usr/local/go/bin:$WORKSPACE/gopath/bin -e GOCACHE=$WORKSPACE/gopath/.cache'
        }
	  }
	  steps {
	      dir("gopath/src/github.com/Microsoft/oe-engine") {
            sh 'ls'
            sh 'pwd'
	        sh 'make test'
	        sh 'make build'
	        withCredentials([usernamePassword(credentialsId: '40060061-6050-40f7-ac6a-53aeb767245f', passwordVariable: 'SERVICE_PRINCIPAL_PASSWORD', usernameVariable: 'SERVICE_PRINCIPAL_ID')]) {
              sh 'AZURE_CONFIG_DIR=$(pwd) test/acc-pr-test.sh'
            }
	    }
	  }
	}
  }
}
