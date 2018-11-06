    {
      "apiVersion": "2018-02-01",
      "name": "pid-daeec781-52c2-488a-85a6-7945b7831056",
      "type": "Microsoft.Resources/deployments",
      "properties": {
        "mode": "Incremental",
        "template": {
          "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
          "contentVersion": "1.0.0.0",
          "resources": []
        }
      }
    },
    {
      "condition": "[equals(variables('diagnosticsStorageAction'), 'new')]",
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2018-02-01",
      "name": "[parameters('diagnosticsStorageAccountName')]",
      "location": "[parameters('location')]",
      "kind": "[parameters('diagnosticsStorageAccountKind')]",
      "sku": {
        "name": "[parameters('diagnosticsStorageAccountType')]"
      }
    },
{{if HasWindowsCustomImage}}
    {
      "type": "Microsoft.Compute/images",
      "apiVersion": "2018-06-01",
      "name": "CustomWindowsImage",
      "location": "[parameters('location')]",
      "properties": {
        "storageProfile": {
          "osDisk": {
            "osType": "Windows",
            "osState": "Generalized",
            "blobUri": "[parameters('windowsImageSourceUrl')]",
            "storageAccountType": "Standard_LRS"
          }
        }
      }
    },
{{end}}
{{if HasLinuxCustomImage}}
    {
      "type": "Microsoft.Compute/images",
      "apiVersion": "2018-06-01",
      "name": "CustomLinuxImage",
      "location": "[parameters('location')]",
      "properties": {
        "storageProfile": {
          "osDisk": {
            "osType": "Linux",
            "osState": "Generalized",
            "blobUri": "[parameters('linuxImageSourceUrl')]",
            "storageAccountType": "Standard_LRS"
          }
        }
      }
    },
{{end}}
    {
      "condition": "[equals(parameters('vnetNewOrExisting'), 'new')]",
      "apiVersion": "2018-06-01",
      "location": "[parameters('location')]",
      "name": "[parameters('vnetName')]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[parameters('vnetAddress')]"
          ]
        },
        "subnets": [
          {
            "name": "[parameters('subnetName')]",
            "properties": {
              "addressPrefix": "[parameters('subnetAddress')]"
            }
          }
        ]
      },
      "type": "Microsoft.Network/virtualNetworks"
    }
    