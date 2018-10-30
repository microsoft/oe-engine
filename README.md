
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
