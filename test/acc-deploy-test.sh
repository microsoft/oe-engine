#!/bin/bash

set -e

azure_cli_login() {
    # Check if we are already logged in
    if az account list --output json | jq -r '.[0]["user"]["name"]' | grep -q "^${SERVICE_PRINCIPAL_ID}$"; then
        echo "Account is already logged"
        return 0
    fi
    # Login
    az login --output table --service-principal -u $SERVICE_PRINCIPAL_ID -p $SERVICE_PRINCIPAL_PASSWORD --tenant $TENANT || {
        echo "ERROR: Failed to login into Azure"
        return 1
    }
    az account set --subscription ${SUBSCRIPTION_ID}
}

validate_environment_variables() {
    if [[ -z "${SUBSCRIPTION_ID:-}" ]]; then echo "Must specify SUBSCRIPTION_ID"; exit 1; fi
    if [[ -z "${TENANT:-}" ]]; then echo "Must specify TENANT"; exit 1; fi

    if [[ -z "${SERVICE_PRINCIPAL_ID:-}" ]]; then echo "Must specify SERVICE_PRINCIPAL_ID"; exit 1; fi
    if [[ -z "${SERVICE_PRINCIPAL_PASSWORD:-}" ]]; then echo "Must specify SERVICE_PRINCIPAL_PASSWORD"; exit 1; fi

    if [[ -z "${IMAGE:-}" ]]; then echo "Must specify IMAGE"; exit 1; fi
    if [[ -z "${LOCATION:-}" ]]; then echo "Must specify LOCATION"; exit 1; fi

    if [[ -z "${KV_NAME:-}" ]]; then echo "Must specify KV_NAME"; exit 1; fi
    if [[ -z "${KV_SECRET_SSH_PUB:-}" ]]; then echo "Must specify KV_SECRET_SSH_PUB"; exit 1; fi
    if [[ -z "${KV_SECRET_WIN_PWD:-}" ]]; then echo "Must specify KV_SECRET_WIN_PWD"; exit 1; fi
}

get_ssh_keypair() {
    export SSH_DIR="$(pwd)/.ssh"
    if [ -d "$SSH_DIR" ]; then rm -Rf $SSH_DIR; fi
    mkdir $SSH_DIR
    # Download private/public keys secrets from Azure key vault
    echo "Downloading ssh private keypair from key vault"
    az keyvault secret download --vault-name "${KV_NAME}" --name "${KV_SECRET_SSH_PRIV}" --file "${SSH_DIR}/id_rsa.b64" || {
        echo "ERROR: Failed to download private key from Azure key vault ${KV_NAME}"
        return 1
    }
    # Decode private key
    base64 -d "${SSH_DIR}/id_rsa.b64" > ${SSH_DIR}/id_rsa || {
        echo "ERROR: Failed to decode private key"
        return 1
    }
    chmod 600 ${SSH_DIR}/id_rsa
    echo "Downloading ssh public key from key vault"
    az keyvault secret download --vault-name "${KV_NAME}" --name "${KV_SECRET_SSH_PUB}" --file "${SSH_DIR}/id_rsa.pub.b64" || {
        echo "ERROR: Failed to download public key from Azure key vault ${KV_NAME}"
        return 1
    }
    # Decode public key
    base64 -d "${SSH_DIR}/id_rsa.pub.b64" > ${SSH_DIR}/id_rsa.pub || {
        echo "ERROR: Failed to decode private key"
        return 1
    }
    # Export downloaded public key as variable
    export SSH_PRIV_KEY="${SSH_DIR}/id_rsa"
    export SSH_PUB_KEY=$(cat ${SSH_DIR}/id_rsa.pub)
}

function cleanup {
    set +e
    if [ "$IMAGE" = "Windows" ]; then
      PUBLIC_IP=$(az vm show -d -g ${RGNAME} -n accwin --query publicIps -o tsv)
      echo "Downloading provisionScript.log from Windows Agent"
      scp -o 'LogLevel=quiet' -o 'PasswordAuthentication=no' -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ${SSH_PRIV_KEY} "azureuser@${PUBLIC_IP}:/Azuredata/provisionScript.log" .
    fi
    if [ "$IMAGE" = "Ubuntu18.04" ]; then
      PUBLIC_IP=$(az vm show -d -g ${RGNAME} -n acc-ub1804 --query publicIps -o tsv)
      echo "Downloading cloud-init logs from Ubuntu 18.04"
      scp -o 'LogLevel=quiet' -o 'PasswordAuthentication=no' -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ${SSH_PRIV_KEY} "azureuser@${PUBLIC_IP}:/var/log/cloud-init*.log" .
      echo "Downloading deployment logs from Ubuntu 18.04"
      scp -o 'LogLevel=quiet' -o 'PasswordAuthentication=no' -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ${SSH_PRIV_KEY} "azureuser@${PUBLIC_IP}:/opt/azure/acc/*.log" .
    fi
    if [ "$IMAGE" = "Ubuntu16.04" ]; then
      PUBLIC_IP=$(az vm show -d -g ${RGNAME} -n acc-ub1604 --query publicIps -o tsv)
      echo "Downloading cloud-init logs from Ubuntu 16.04"
      scp -o 'LogLevel=quiet' -o 'PasswordAuthentication=no' -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ${SSH_PRIV_KEY} "azureuser@${PUBLIC_IP}:/var/log/cloud-init*.log" .
      echo "Downloading deployment logs from Ubuntu 16.04"
      scp -o 'LogLevel=quiet' -o 'PasswordAuthentication=no' -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ${SSH_PRIV_KEY} "azureuser@${PUBLIC_IP}:/opt/azure/acc/*.log" .
    fi
    set -e
    az group delete --name $RGNAME --yes --no-wait
    if [ -d "$SSH_DIR" ]; then rm -Rf $SSH_DIR; fi
}

validate_environment_variables
azure_cli_login
get_ssh_keypair

if [ -z "${OE_ENGINE_BIN}" ]; then
  echo "Download oe-engine binary from the cloud"
  wget -q https://oejenkinsciartifacts.blob.core.windows.net/oe-engine/latest/bin/oe-engine
  chmod 755 oe-engine
  OE_ENGINE_BIN="./oe-engine"
fi

if [ "$IMAGE" = "Ubuntu16.04" ]; then
  sed -i "/\"keyData\":/c \"keyData\": \"${SSH_PUB_KEY}\"" oe-ub1604.json
  ${OE_ENGINE_BIN} generate --api-model oe-ub1604.json
elif [ "$IMAGE" = "Ubuntu18.04" ]; then
  sed -i "/\"keyData\":/c \"keyData\": \"${SSH_PUB_KEY}\"" oe-ub1804.json
  ${OE_ENGINE_BIN} generate --api-model oe-ub1804.json
elif [ "$IMAGE" = "Windows" ]; then
  ADMIN_PASSWORD=$(az keyvault secret show --vault-name ${KV_NAME} --name ${KV_SECRET_WIN_PWD} | jq -r .value)
  sed -i "/\"adminPassword\":/c \"adminPassword\": \"${ADMIN_PASSWORD}\"," oe-win.json
  sed -i "/\"sshPublicKey\":/c \"sshPublicKey\": \"${SSH_PUB_KEY}\"" oe-win.json
  ${OE_ENGINE_BIN} generate --api-model oe-win.json
else
  echo "Unsupported IMAGE $IMAGE"
  exit 1
fi

# Deployment
RGNAME="acc-${IMAGE}-${LOCATION}-${BUILD_NUMBER}"
az group create --name $RGNAME --location $LOCATION
trap cleanup EXIT
az group deployment create -n acc-lnx -g $RGNAME --template-file _output/azuredeploy.json --parameters _output/azuredeploy.parameters.json
