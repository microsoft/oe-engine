#!/usr/bin/env groovy

pipeline {
  agent {
    docker {
      image 'golang:1.11.0'
      label 'nonSGX'
      args  '-e GOPATH=$WORKSPACE -e GOROOT=$WORKSPACE/go -e PATH=$PATH:/usr/local/go/bin:$WORKSPACE/go/bin -e GOCACHE=$WORKSPACE/.cache'
    }
  }
  environment {
    SUBSCRIPTION_ID = credentials('OSCTLabSubID')
    TENANT_ID = credentials('TenantID')
  }
  stages {
	stage('unit-test') {  
	  steps {
        sh 'mkdir go'
        sh 'ls'
        sh 'pwd'
        sh 'id'
        sh 'echo $GOPATH'
        sh 'echo $GOROOT'
	    sh 'make test'
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
