#!/usr/bin/env groovy

pipeline {
  agent {
    docker {
      image 'ubuntu18.04-dev'
      label 'nonSGX'
      args  '-e GOPATH=$WORKSPACE/gopath -e GOROOT=/usr/local/go -e PATH=$PATH:/usr/local/go/bin:$WORKSPACE/gopath/bin -e GOCACHE=$WORKSPACE/gopath/.cache'
    }
  }
  environment {
    SUBSCRIPTION_ID = credentials('OSCTLabSubID')
    TENANT_ID = credentials('TenantID')
  }
  stages {
    stage('clone') {
      steps {
        dir('gopath/src/github.com/Microsoft/oe-engine') {
          checkout scm
        }
      }
    }
	stage('unit-test') {
	  steps {
        dir('gopath/src/github.com/Microsoft/oe-engine') {
	      sh 'echo make test'
        }
      }
    }
    stage('build') { 
      steps {
        dir('gopath/src/github.com/Microsoft/oe-engine') {
          sh 'make build'
        }
      }
    }
    stage('run') { 
      steps {
        dir('gopath/src/github.com/Microsoft/oe-engine') {
          withCredentials([usernamePassword(credentialsId: 'SERVICE_PRINCIPAL_OSTCLAB', passwordVariable: 'SERVICE_PRINCIPAL_PASSWORD', usernameVariable: 'SERVICE_PRINCIPAL_ID')]) {
            sh 'AZURE_CONFIG_DIR=$(pwd) test/acc-pr-test.sh'
          }
        }
      }
    }
  }
}
