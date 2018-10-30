# Deployment of ACC VMs

Typical deployment consist of the following steps:

### Build oe-engine
```sh
git clone https://github.com/Microsoft/oe-engine
cd oe-engine
make build
```
Alternatively you can download latest release from https://github.com/Microsoft/oe-engine/releases
### Create VM definition file
The VM definition file is a JSON document, that describes properties of the VMs, such as compute power, OS image, credentials, etc.
The syntax of the file is self-explanatory. The examples below illustrate how to set various properties.

* [Multi-VM deployment](docs/examples/oe-multi-vm.json) - Deploying multiple VMs
* [Existing VNET](docs/examples/oe-vnet.json) - Deploying VMs into existing VNET
* [Enabling boot diagnostics](docs/examples/oe-bootdiagnostics.json) - Creating new or using existing storage account for boot diagnostics
* [vanila VM deployment](docs/examples/oe-vanila.json) - Skipping installation of OE SDK
* [Linux user password](docs/examples/oe-lnx-passwd.json) - Using Linux user password instead of public SSH key
* [Windows OpenSSH](docs/examples/oe-win-ssh.json) - Installing and configuring OpenSSH on Windows VMs

The table below summarizes enumerated properties

| Property | Key | Values |
| ------ | ------ |------ |
| OS | osImageName | `UbuntuServer_16.04` `WindowsServer_2016` |
| Compute| vmSize | `Standard_DC2s` `Standard_DC4s` |

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
