@Library("OpenEnclaveCommon") _
oe = new jenkins.common.Openenclave()

// The below timeout is set in minutes
GLOBAL_TIMEOUT = 240

OETOOLS_REPO = "https://oejenkinscidockerregistry.azurecr.io"
OETOOLS_REPO_CREDENTIAL_ID = "oejenkinscidockerregistry"
OETOOLS_DOCKERHUB_REPO_CREDENTIAL_ID = "oeciteamdockerhub"

def buildDockerImages() {
    node("nonSGX") {
        timeout(GLOBAL_TIMEOUT) {
            stage("Checkout") {
                cleanWs()
                checkout scm
            }
            String buildArgs = oe.dockerBuildArgs("UID=\$(id -u)", "UNAME=\$(id -un)",
                                                  "GID=\$(id -g)", "GNAME=\$(id -gn)")
            stage("Build Ubuntu Deploy Docker image") {
                oeEngine = oe.dockerImage("oe-engine:${DOCKER_TAG}", "test/Dockerfile", buildArgs)
                puboeEngine = oe.dockerImage("oeciteam/oe-engine:${DOCKER_TAG}", "test/Dockerfile", buildArgs)
            }
            stage("Push to OE Docker Registry") {
                docker.withRegistry(OETOOLS_REPO, OETOOLS_REPO_CREDENTIAL_ID) {
                    oeEngine.push()
                    if(TAG_LATEST == "true") {
                        oeEngine.push('latest')
                    }
                }
            }
            stage("Push to OE Docker Hub Registry") {
                docker.withRegistry('', OETOOLS_DOCKERHUB_REPO_CREDENTIAL_ID) {
                    puboeEngine.push()
                    if(TAG_LATEST == "true") {
                        puboeEngine.push('latest')
                    }
                }
            }
        }
    }
}

buildDockerImages()
