#!/bin/bash

if [[ -z "${SUBSCRIPTION_ID:-}" ]]; then echo "Must specify SUBSCRIPTION_ID"; exit 1; fi
if [[ -z "${TENANT:-}" ]]; then echo "Must specify TENANT"; exit 1; fi

if [[ -z "${SP_ID:-}" ]]; then echo "Must specify SP_ID"; exit 1; fi
if [[ -z "${SP_PWD:-}" ]]; then echo "Must specify SP_PWD"; exit 1; fi

if [[ -z "${LOCATION:-}" ]]; then echo "Must specify LOCATION"; exit 1; fi

az login --service-principal -u ${SP_ID} -p ${SP_PWD} --tenant $TENANT
az account set --subscription ${SUBSCRIPTION_ID}

SSH_PUB_KEY=$(az keyvault secret show --vault-name oe-ci-test-kv --name id-rsa-oe-test-pub | jq -r .value | base64 -d)

sed -i "/\"keyData\":/c \"keyData\": \"${SSH_PUB_KEY}\"" oe-lnx.json

wget https://oejenkinsciartifacts.blob.core.windows.net/oe-engine/latest/bin/oe-engine
chmod 755 oe-engine

./oe-engine generate --api-model oe-lnx.json

RGNAME="acc-lnx-${LOCATION}-${BUILD_NUMBER}"
az group create --name $RGNAME --location $LOCATION
az group deployment create -n acc-lnx -g $RGNAME --template-file _output/azuredeploy.json --parameters _output/azuredeploy.parameters.json
