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
          git branch: 'master', credentialsId: 'oe-engine-ro-deploy-key', url: 'git@github.com:Microsoft/oe-engine'
          sh 'rm -rf work'
          sh 'mkdir work'
          sh 'cp test/oe-lnx.json test/oe-win.json work/'
          withCredentials([usernamePassword(credentialsId: '40060061-6050-40f7-ac6a-53aeb767245f', passwordVariable: 'SERVICE_PRINCIPAL_PASSWORD', usernameVariable: 'SERVICE_PRINCIPAL_ID')]) {
            sh 'cd work; AZURE_CONFIG_DIR=. ../test/acc-deploy-test.sh'
          }
        }
      }
    }
  }
}
