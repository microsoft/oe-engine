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
    stage('Checkout') {
      steps {
        dir('gopath/src/github.com/Microsoft/oe-engine') {
          checkout scm
        }
      }
    }
	stage('Unit-test') {
	  steps {
        dir('gopath/src/github.com/Microsoft/oe-engine') {
          sh 'find .'
  	      sh 'echo make test'
        }
      }
    }
    stage('Build') {
      steps {
        dir('gopath/src/github.com/Microsoft/oe-engine') {
          sh 'make build'
          stash includes: 'bin/**/*', name: 'bin'
          stash includes: 'test/**/*.json', name: 'config'
        }
      }
    }
    stage('Test') {
      failFast true
      parallel {
        stage('Linux') {
          agent {
            docker {
              image 'ubuntu18.04-dev'
              label 'nonSGX'
            }
          }
          steps {
            unstash 'bin'
            unstash 'config'
            sh 'find .'
          }
        }
        stage('Windows') {
          agent {
            docker {
              image 'ubuntu18.04-dev'
              label 'nonSGX'
            }
          }
          steps {
            unstash 'bin'
            unstash 'config'
            sh 'find .'
          }
        }
      }
    }
  }
}
