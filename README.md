
# OpenEnclave Engine - Azure template generator for SGX-capable VMs

OpenEnclave Engine `oe-engine` generates ARM (Azure Resource Manager) template for a set of SGX-capable virtual machines.

The input to the tool is a JSON file describing the VM set. For example:

```
{
  "properties": {
    "vmProfiles": [
      {
        "name": "acc1",
        "osImageName": "UbuntuServer_16.04",
        "vmSize": "Standard_DC2s"
      },
      {
        "name": "acc2",
        "osImageName": "WindowsServer_2016",
        "vmSize": "Standard_DC2s"
      }
    ],
    "linuxProfile": {
      "adminUsername": "<Linux admin user name>",
      "sshPublicKey": "<SSH public key>"
    },
    "windowsProfile": {
      "adminUsername": "<Windows admin user name>",
      "adminPassword": "<Windows admin password>",
      "sshPublicKey": "<SSH public key (optional)>"
    }
  }
}
```

Typical deployment consist of the following steps:

1. Login to Azure
```sh
az login
```
2. Set the default subscription for your account if it has multiple active subscriptions
```sh
az account set --subscription "<subscription name>"
```
3. Create VM set JSON definition file
4.  Generate ARM template
```sh
oe-engine generate --api-model <VM-set JSON file>
```
5.  Create resource group
```sh
az group create -l eastus -n <resource group name>
```
6. Deploy VMs
```sh
az group deployment create --name <deployment name> --resource-group <resource group name>
  --template-file _output/azuredeploy.json
  --parameters @_output/azuredeploy.parameters.json
```
# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
