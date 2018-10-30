    {
      "apiVersion": "2018-06-01",
      "location": "[parameters('location')]",
      "name": "[variables('{{.Name}}PublicIPAddressName')]",
      "properties": {
        "publicIPAllocationMethod": "Dynamic"
      },
      "type": "Microsoft.Network/publicIPAddresses"
    },
    {
      "apiVersion": "2018-06-01",
      "location": "[parameters('location')]",
      "name": "[variables('{{.Name}}NSGName')]",
      "properties": {
        "securityRules": "[if(equals(parameters('publicInboundPorts'), 'enable'), variables('{{.Name}}SecurityRules'), json('null'))]"
      },
      "type": "Microsoft.Network/networkSecurityGroups"
    },
    {
      "apiVersion": "2018-06-01",
      "dependsOn": [
        "[variables('{{.Name}}PublicIPAddressName')]",
        "[parameters('vnetName')]",
        "[variables('{{.Name}}NSGID')]"
      ],
      "location": "[parameters('location')]",
      "name": "[concat('{{.Name}}', '-nic')]",
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
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('{{.Name}}PublicIPAddressName'))]"
              }
            }
          }
        ]
        ,"networkSecurityGroup": {
          "id": "[variables('{{.Name}}NSGID')]"
        }
      },
      "type": "Microsoft.Network/networkInterfaces"
    },
{{if HasWindowsCustomImage}}
    {
      "condition": "[equals(parameters('{{.Name}}OSImageName'), 'WindowsServer_2016')]",
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
    {
      "apiVersion": "2018-06-01",
      "dependsOn": [
        "[concat('Microsoft.Network/networkInterfaces/', '{{.Name}}', '-nic')]"
      ],
      "tags":
      {
        "creationSource" : "[concat('oe-engine-', '{{.Name}}')]"
      },
      "location": "[parameters('location')]",
      "name": "{{.Name}}",
      "properties": {
        "hardwareProfile": {
          "vmSize": "[parameters('{{.Name}}VMSize')]"
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces', concat('{{.Name}}', '-nic'))]"
            }
          ]
        },
        "osProfile": "[if(equals(parameters('{{.Name}}OSImageName'), 'WindowsServer_2016'), variables('{{.Name}}WindowsOsProfile'), variables('{{.Name}}LinuxOsProfile'))]",
        "storageProfile": "[if(equals(parameters('{{.Name}}OSImageName'), 'WindowsServer_2016'), variables('{{.Name}}WindowsStorageProfile'), variables('{{.Name}}LinuxStorageProfile'))]",
        "diagnosticsProfile": {
          "bootDiagnostics": {
            "enabled": "[equals(parameters('bootDiagnostics'), 'enable')]",
            "storageUri": "[if(equals(parameters('bootDiagnostics'), 'enable'), reference(resourceId(parameters('diagnosticsStorageAccountResourceGroupName'), 'Microsoft.Storage/storageAccounts', parameters('diagnosticsStorageAccountName')), '2018-02-01').primaryEndpoints['blob'], json('null'))]"
          }
        }
      },
      "type": "Microsoft.Compute/virtualMachines"
    },
    {
      "condition": "[equals(parameters('{{.Name}}OSImageName'), 'UbuntuServer_16.04')]",
      "apiVersion": "2018-06-01",
      "dependsOn": [
        "{{.Name}}"
      ],
      "location": "[parameters('location')]",
      "name": "[concat('{{.Name}}', '/validateLnx')]",
      "properties": {
        "publisher": "Microsoft.OSTCExtensions",
        "type": "CustomScriptForLinux",
        "typeHandlerVersion": "1.4",
        "autoUpgradeMinorVersion": true,
        "settings": {
          "commandToExecute": "[variables('linuxExtCommand')]"
        }
      },
      "type": "Microsoft.Compute/virtualMachines/extensions"
    },
    {
      "condition": "[equals(parameters('{{.Name}}OSImageName'), 'WindowsServer_2016')]",
      "apiVersion": "2018-06-01",
      "dependsOn": [
        "{{.Name}}"
      ],
      "location": "[parameters('location')]",
      "type": "Microsoft.Compute/virtualMachines/extensions",
      "name": "[concat('{{.Name}}', '/validateWin')]",
      "properties": {
        "publisher": "Microsoft.Compute",
        "type": "CustomScriptExtension",
        "typeHandlerVersion": "1.8",
        "autoUpgradeMinorVersion": true,
        "settings": {},
        "protectedSettings": {
          "commandToExecute": "[variables('windowsExtScript')]"
        }
      }
    },
