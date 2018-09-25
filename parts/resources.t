    {
      "condition": "[equals(variables('diagnosticsStorageAction'), 'new')]",
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "[variables('apiVersionStorage')]",
      "name": "[parameters('diagnosticsStorageAccountName')]",
      "location": "[parameters('location')]",
      "kind": "[parameters('diagnosticsStorageAccountKind')]",
      "sku": {
        "name": "[parameters('diagnosticsStorageAccountType')]"
      }
    },
    {
      "condition": "[equals(parameters('vnetNewOrExisting'), 'new')]",
      "apiVersion": "[variables('apiVersionDefault')]",
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
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "location": "[parameters('location')]",
      "name": "[variables('publicIPAddressName')]",
      "properties": {
        "publicIPAllocationMethod": "Dynamic"
      },
      "type": "Microsoft.Network/publicIPAddresses"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "location": "[parameters('location')]",
      "name": "[variables('nsgName')]",
      "properties": {
        "securityRules": "[if(equals(parameters('publicInboundPorts'), 'enable'), variables('securityRules'), json('null'))]"
      },
      "type": "Microsoft.Network/networkSecurityGroups"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "dependsOn": [
        "[variables('publicIPAddressName')]",
        "[parameters('vnetName')]",
        "[variables('nsgID')]"
      ],
      "location": "[parameters('location')]",
      "name": "[concat(parameters('vmName'), '-nic')]",
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipConfigNode",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[variables('vnetSubnetID')]"
              },
              "publicIpAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('publicIPAddressName'))]"
              }
            }
          }
        ]
        ,"networkSecurityGroup": {
          "id": "[variables('nsgID')]"
        }
      },
      "type": "Microsoft.Network/networkInterfaces"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "dependsOn": [
        "[concat('Microsoft.Network/networkInterfaces/', parameters('vmName'), '-nic')]"
      ],
      "tags":
      {
        "creationSource" : "[concat('oe-engine-', parameters('vmName'))]"
      },
      "location": "[parameters('location')]",
      "name": "[parameters('vmName')]",
      "plan": "[if(equals(parameters('osImageName'), 'WindowsServer_2016'), json('null'), variables('plan'))]",
      "properties": {
        "hardwareProfile": {
          "vmSize": "[parameters('vmSize')]"
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces',concat(parameters('vmName'), '-nic'))]"
            }
          ]
        },
        "osProfile": {
          "computername": "[parameters('vmName')]",
          "adminUsername": "[variables('adminUsername')]",
          "adminPassword": "[if(equals(parameters('authenticationType'), 'password'), parameters('adminPasswordOrKey'), '')]",
          "customData": "[if(equals(parameters('oeSDKIncluded'), 'no'), json('null'), {{GetCustomData}})]",
          "linuxConfiguration": "[if(equals(parameters('authenticationType'), 'password'), json('null'), variables('linuxConfiguration'))]",
          "windowsConfiguration": "[if(equals(parameters('osImageName'), 'WindowsServer_2016'), variables('windowsConfiguration'), json('null'))]"
          {{if .IsLinux}}{{if .LinuxProfile.HasSecrets}}
          ,
          "secrets": "[variables('linuxProfileSecrets')]"
          {{end}}{{end}}
        },
        "storageProfile": {
          "imageReference": "[variables('imageReference')[parameters('osImageName')]]",
          "osDisk": {
            "caching": "ReadWrite",
            "createOption": "FromImage",
            "managedDisk": {
              "storageAccountType": "[parameters('osDiskType')]"
            }
          }
        },
        "diagnosticsProfile": "[if(equals(parameters('bootDiagnostics'), 'enable'), variables('diagnosticsProfile'), json('null'))]"
      },
      "type": "Microsoft.Compute/virtualMachines"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "dependsOn": [
        "[parameters('vmName')]"
      ],
      "location": "[parameters('location')]",
      "name": "[concat(parameters('vmName'), '/validate')]",
      "properties": "[if(equals(parameters('osImageName'), 'WindowsServer_2016'), variables('windowsExtensionProperties'), variables('linuxExtensionProperties'))]",
      "type": "Microsoft.Compute/virtualMachines/extensions"
    }{{WriteLinkedTemplatesForExtensions}}
