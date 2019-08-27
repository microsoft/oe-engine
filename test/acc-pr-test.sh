#!/bin/bash

set -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd $DIR

function cleanup {
    set +e
    if [ "$API_MODEL" = "oe-win.json" ]; then
      mkdir -p "${LOG_DIR}/oe-win"
      PUBLIC_IP=$(az vm show -d -g ${RGNAME} -n accwin --query publicIps -o tsv)
      echo "Downloading provisionScript.log from Windows Agent"
      scp -o 'LogLevel=quiet' -o 'PasswordAuthentication=no' -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ${SSH_PRIV_KEY} "azureuser@${PUBLIC_IP}:/Azuredata/provisionScript.log" "${LOG_DIR}/oe-win"
    fi
    if [ "$API_MODEL" = "oe-ub1804.json" ]; then
      mkdir -p "${LOG_DIR}/oe-ub1804"
      PUBLIC_IP=$(az vm show -d -g ${RGNAME} -n acc-ub1804 --query publicIps -o tsv)
      echo "Downloading cloud-init logs from Ubuntu 18.04"
      scp -o 'LogLevel=quiet' -o 'PasswordAuthentication=no' -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ${SSH_PRIV_KEY} "azureuser@${PUBLIC_IP}:/var/log/cloud-init*.log" "${LOG_DIR}/oe-ub1804"
      echo "Downloading deployment logs from Ubuntu 18.04"
      scp -o 'LogLevel=quiet' -o 'PasswordAuthentication=no' -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ${SSH_PRIV_KEY} "azureuser@${PUBLIC_IP}:/opt/azure/acc/*.log" "${LOG_DIR}/oe-ub1804"
    fi
    if [ "$API_MODEL" = "oe-ub1604.json" ]; then
      mkdir -p "${LOG_DIR}/oe-ub1604"
      PUBLIC_IP=$(az vm show -d -g ${RGNAME} -n acc-ub1604 --query publicIps -o tsv)
      echo "Downloading cloud-init logs from Ubuntu 16.04"
      scp -o 'LogLevel=quiet' -o 'PasswordAuthentication=no' -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ${SSH_PRIV_KEY} "azureuser@${PUBLIC_IP}:/var/log/cloud-init*.log" "${LOG_DIR}/oe-ub1604"
      echo "Downloading deployment logs from Ubuntu 16.04"
      scp -o 'LogLevel=quiet' -o 'PasswordAuthentication=no' -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ${SSH_PRIV_KEY} "azureuser@${PUBLIC_IP}:/opt/azure/acc/*.log" "${LOG_DIR}/oe-ub1604"
   fi
    set -e
    az group delete --name $RGNAME --yes --no-wait
    if [ -d "$SSH_DIR" ]; then rm -Rf $SSH_DIR; fi
}

validate_environment_variables() {
    if [[ -z "${API_MODEL:-}" ]]; then echo "Usage: $0 <api-model>"; exit 1; fi
    if [[ -z "${SUBSCRIPTION_ID:-}" ]]; then echo "Must specify SUBSCRIPTION_ID"; exit 1; fi
    if [[ -z "${TENANT_ID:-}" ]]; then echo "Must specify TENANT_ID"; exit 1; fi

    if [[ -z "${SERVICE_PRINCIPAL_ID:-}" ]]; then echo "Must specify SERVICE_PRINCIPAL_ID"; exit 1; fi
    if [[ -z "${SERVICE_PRINCIPAL_PASSWORD:-}" ]]; then echo "Must specify SERVICE_PRINCIPAL_PASSWORD"; exit 1; fi

    if [[ -z "${LOCATION:-}" ]]; then echo "Must specify LOCATION"; exit 1; fi
}

azure_cli_login() {
    # Check if we are already logged in
    if az account list --output json | jq -r '.[0]["user"]["name"]' | grep -q "^${SERVICE_PRINCIPAL_ID}$"; then
        echo "Account is already logged"
        return 0
    fi
    # Login
    az login --output table --service-principal -u $SERVICE_PRINCIPAL_ID -p $SERVICE_PRINCIPAL_PASSWORD --tenant $TENANT_ID || {
        echo "ERROR: Failed to login into Azure"
        return 1
    }
    az account set --subscription ${SUBSCRIPTION_ID}
}

get_ssh_keypair() {
    export SSH_DIR="${DIR}/.ssh"
    if [ -d "$SSH_DIR" ]; then rm -Rf $SSH_DIR; fi
    mkdir $SSH_DIR
    # Download private/public keys secrets from Azure key vault
    echo "Downloading ssh private keypair from key vault"
    az keyvault secret download --vault-name "oe-ci-test-kv" --name "id-rsa-oe-test" --file "${SSH_DIR}/id_rsa.b64" || {
        echo "ERROR: Failed to download private key from Azure key vault oe-ci-test-kv"
        return 1
    }
    # Decode private key
    base64 -d "${SSH_DIR}/id_rsa.b64" > ${SSH_DIR}/id_rsa || {
        echo "ERROR: Failed to decode private key"
        return 1
    }
    chmod 600 ${SSH_DIR}/id_rsa
    echo "Downloading ssh public key from key vault"
    az keyvault secret download --vault-name "oe-ci-test-kv" --name "id-rsa-oe-test-pub" --file "${SSH_DIR}/id_rsa.pub.b64" || {
        echo "ERROR: Failed to download public key from Azure key vault oe-ci-test-kv"
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

###

API_MODEL=$1
LOCATION=eastus
ADMIN_PASSWORD=$(az keyvault secret show --vault-name oe-ci-test-kv --name windows-pwd | jq -r .value)
LOG_DIR="${DIR}/agent_logs"

validate_environment_variables
azure_cli_login
get_ssh_keypair

sed -i "/\"keyData\":/c \"keyData\": \"${SSH_PUB_KEY}\"" ${API_MODEL}
sed -i "/\"sshPublicKey\":/c \"sshPublicKey\": \"${SSH_PUB_KEY}\"" ${API_MODEL}
sed -i "/\"adminPassword\":/c \"adminPassword\": \"${ADMIN_PASSWORD}\"," ${API_MODEL}

ID=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6)

../bin/oe-engine generate --api-model ${API_MODEL} --output-directory "_output/$ID"

RGNAME="oe-engine-pr-${BUILD_NUMBER}-$ID"
az group create --name $RGNAME --location $LOCATION
trap cleanup EXIT
az group deployment create -n $ID -g $RGNAME --template-file _output/$ID/azuredeploy.json --parameters _output/$ID/azuredeploy.parameters.json
