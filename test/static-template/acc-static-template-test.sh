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

###

function UsageExit
{
  echo "Usage: $0 <OS (Linux|Windows)> <enable OE SDK (yes|no)>"
  exit 1
}

OS=$1
OE_SDK_INCLUDED=$2
LOCATION=eastus

if [ -z "${OS:-}" ] || [ -z "${OE_SDK_INCLUDED:-}" ]; then UsageExit $0; fi
if [ -z "${SUBSCRIPTION_ID:-}" ]; then echo "Must specify SUBSCRIPTION_ID"; exit 1; fi
if [ -z "${TENANT_ID:-}" ]; then echo "Must specify TENANT_ID"; exit 1; fi

if [ -z "${SERVICE_PRINCIPAL_ID:-}" ]; then echo "Must specify SERVICE_PRINCIPAL_ID"; exit 1; fi
if [ -z "${SERVICE_PRINCIPAL_PASSWORD:-}" ]; then echo "Must specify SERVICE_PRINCIPAL_PASSWORD"; exit 1; fi

az login --service-principal -u ${SERVICE_PRINCIPAL_ID} -p ${SERVICE_PRINCIPAL_PASSWORD} --tenant ${TENANT_ID}
az account set --subscription ${SUBSCRIPTION_ID}

TEMPDIR="$(mktemp -d)"
trap "rm -rf \"${TEMPDIR}\"" EXIT

case "$OS" in
Linux)
  cp parameters-lnx.json $TEMPDIR/parameters.json
  SSH_PUB_KEY=$(az keyvault secret show --vault-name ostc-test-kv --name id-rsa-ostc-jenkins-pub | jq -r .value)
  sed -i "s%SSH_PUB_KEY%${SSH_PUB_KEY}%" $TEMPDIR/parameters.json
  case "$OE_SDK_INCLUDED" in
  no)
    echo "Skipping OE-SDK installation"
    ;;
  yes)
    echo "Installing OE-SDK"
    ;;
  *)
    UsageExit $0
    ;;
  esac
  sed -i "s/OE_SDK_INCLUDED/${OE_SDK_INCLUDED}/" $TEMPDIR/parameters.json
  ;;
Windows)
  cp parameters-win.json $TEMPDIR/parameters.json
  PASSWORD=$(az keyvault secret show --vault-name ostc-test-kv --name windows-password | jq -r .value)
  sed -i "s/PASSWORD/${PASSWORD}/" $TEMPDIR/parameters.json
  ;;
*)
  UsageExit $0
  ;;
esac

ID=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6)
RGNAME="acc-marketplace-${BUILD_NUMBER}-$ID"

az group create --name $RGNAME --location $LOCATION
trap 'az group delete --name $RGNAME --yes --no-wait; rm -rf $TEMPDIR' EXIT

sed -i "s/LOCATION/${LOCATION}/" $TEMPDIR/parameters.json
sed -i "s/RGNAME/${RGNAME}/" $TEMPDIR/parameters.json

az group deployment create -n $ID -g $RGNAME --template-file template.json --parameters @${TEMPDIR}/parameters.json
