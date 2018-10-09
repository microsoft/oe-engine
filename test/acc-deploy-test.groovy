pipeline {
  agent any
  stages {
	stage('build') {
	  agent {
	    docker {
          image 'ubuntu-1804-dev'
          label 'nonSGX'
        }
	  }
	  steps {
	      dir("gopath/src/github.com/Microsoft/oe-engine") {
	        git branch: 'ds-acc-deploy-test', credentialsId: 'oe-engine-ro-deploy-key', url: 'git@github.com:Microsoft/oe-engine'
	        sh 'rm -rf work'
	        sh 'mkdir work'
	        sh 'cp test/oe-lnx.json work/'
            sh 'cd work; LOCATION=eastus AZURE_CONFIG_DIR=. ../test/acc-deploy-test.sh'
	      }
	  }
	}
  }
}
