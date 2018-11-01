# Deployment of ACC VMs

A typical deployment consists of the following steps:

### Build oe-engine
```sh
git clone https://github.com/Microsoft/oe-engine
cd oe-engine
make build
```
Alternatively, you can download latest release from [here](https://github.com/Microsoft/oe-engine/releases)

### Create VM definition file
The VM definition file is a JSON-formatted description of the properties of the VMs, such as: compute power, OS image, credentials, etc.

For details, refer to the [Setting properties in the VM definition file](properties.md)

The examples below illustrate how to set the various properties.

* [Multi-VM deployment](examples/oe-multi-vm.json) - Deploying multiple VMs
* [Existing VNET](examples/oe-vnet.json) - Deploying VMs into an existing virtual network
* [Enabling boot diagnostics](examples/oe-bootdiagnostics.json) - Creating a new storage account, or using an existing storage account for boot diagnostics
* [Vanilla VM deployment](examples/oe-vanilla.json) - Skipping installation of the Open Enclave SDK
* [Linux user password](examples/oe-lnx-passwd.json) - Using password authentication instead of SSH on Linux
* [Windows OpenSSH](examples/oe-win-ssh.json) - Installing and configuring OpenSSH on Windows

## Generate deployment template

`oe-engine` generates 3 files:
* `azuredeploy.json` - ARM deployment template
* `azuredeploy.parameters.json` - template parameters file
* `apimodel.json` - full VM definition file (all omitted parameters are explicitly set to default values)

```sh
oe-engine generate --api-model <VM definition file>
```

By default `oe-engine` creates `./_output` directory and places generated files there.
You can set output directory with the `--output-directory` parameter.

## Deploy in Azure

Login to Azure
```sh
az login
```
Set the default subscription for your account if it has multiple active subscriptions
```sh
az account set --subscription <subscription id>
```
Create resource group. Currently SGX VMs are only supported in `eastus` and `westeurope` regions.
```sh
az group create -l eastus -n <resource group name>
```
Deploy VMs
```sh
az group deployment create --name <deployment name> --resource-group <resource group name>
  --template-file _output/azuredeploy.json
  --parameters @_output/azuredeploy.parameters.json
```
