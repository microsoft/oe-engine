#!/bin/bash

set -e

if [[ -z "${SUBSCRIPTION_ID:-}" ]]; then echo "Must specify SUBSCRIPTION_ID"; exit 1; fi
if [[ -z "${TENANT:-}" ]]; then echo "Must specify TENANT"; exit 1; fi

if [[ -z "${SERVICE_PRINCIPAL_ID:-}" ]]; then echo "Must specify SERVICE_PRINCIPAL_ID"; exit 1; fi
if [[ -z "${SERVICE_PRINCIPAL_PASSWORD:-}" ]]; then echo "Must specify SERVICE_PRINCIPAL_PASSWORD"; exit 1; fi

az login --service-principal -u ${SERVICE_PRINCIPAL_ID} -p ${SERVICE_PRINCIPAL_PASSWORD} --tenant $TENANT
az account set --subscription ${SUBSCRIPTION_ID}

SSH_PUB_KEY=$(az keyvault secret show --vault-name oe-ci-test-kv --name id-rsa-oe-test-pub | jq -r .value | base64 -d)

sed -i "/\"keyData\":/c \"keyData\": \"${SSH_PUB_KEY}\"" oe-lnx.json

cat oe-lnx.json
wget -q https://oejenkinsciartifacts.blob.core.windows.net/oe-engine/latest/bin/oe-engine
chmod 755 oe-engine
ls
./oe-engine generate --api-model oe-lnx.json
ls

for LOCATION in eastus westeurope
do
  RGNAME="acc-lnx-${LOCATION}-${BUILD_NUMBER}"
  az group create --name $RGNAME --location $LOCATION
  trap 'az group delete --name $RGNAME --yes --no-wait' EXIT
  az group deployment create -n acc-lnx -g $RGNAME --template-file _output/azuredeploy.json --parameters _output/azuredeploy.parameters.json
done
