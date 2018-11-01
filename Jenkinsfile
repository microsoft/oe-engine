#!/usr/bin/env groovy

pipeline {
  agent {
    docker {
      image 'golang:1.11.0'
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
          sh 'ls'
          sh 'pwd'
          sh 'id'
          sh 'echo $GOPATH'
          sh 'echo $GOROOT'
	      sh 'make test'
        }
      }
    }
    stage('build') { 
      steps {
        sh 'make build'
        withCredentials([usernamePassword(credentialsId: '40060061-6050-40f7-ac6a-53aeb767245f', passwordVariable: 'SERVICE_PRINCIPAL_PASSWORD', usernameVariable: 'SERVICE_PRINCIPAL_ID')]) {
          sh 'AZURE_CONFIG_DIR=$(pwd) test/acc-pr-test.sh'
        }
      }
    }
  }
}
