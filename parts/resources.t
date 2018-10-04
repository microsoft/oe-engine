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
    },
    {
      "apiVersion": "2018-06-01",
      "location": "[parameters('location')]",
      "name": "[variables('publicIPAddressName')]",
      "properties": {
        "publicIPAllocationMethod": "Dynamic"
      },
      "type": "Microsoft.Network/publicIPAddresses"
    },
    {
      "apiVersion": "2018-06-01",
      "location": "[parameters('location')]",
      "name": "[variables('nsgName')]",
      "properties": {
        "securityRules": "[if(equals(parameters('publicInboundPorts'), 'enable'), variables('securityRules'), json('null'))]"
      },
      "type": "Microsoft.Network/networkSecurityGroups"
    },
    {
      "apiVersion": "2018-06-01",
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
{{if HasWindowsCustomImage}}
    {"type": "Microsoft.Compute/images",
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
        "[concat('Microsoft.Network/networkInterfaces/', parameters('vmName'), '-nic')]"
      ],
      "tags":
      {
        "creationSource" : "[concat('oe-engine-', parameters('vmName'))]"
      },
      "location": "[parameters('location')]",
      "name": "[parameters('vmName')]",
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
          "adminPassword": "[parameters('adminPasswordOrKey')]",
          "customData": "[if(equals(parameters('oeSDKIncluded'), 'no'), json('null'), {{GetCustomData}})]",
          "linuxConfiguration": "[if(equals(parameters('authenticationType'), 'password'), json('null'), variables('linuxConfiguration'))]",
          "windowsConfiguration": "[if(equals(parameters('osImageName'), 'WindowsServer_2016'), variables('windowsConfiguration'), json('null'))]"
          {{if .IsLinux}}{{if .LinuxProfile.HasSecrets}}
          ,
          "secrets": "[variables('linuxProfileSecrets')]"
          {{end}}{{end}}
        },
        "storageProfile": {
{{if HasWindowsCustomImage}}
        "imageReference": {
          "id": "[resourceId('Microsoft.Compute/images','CustomWindowsImage')]"
        },
{{else}}
          "imageReference": "[variables('imageReference')[parameters('osImageName')]]",
{{end}}
          "osDisk": {
            "caching": "ReadWrite",
            "createOption": "FromImage",
            "managedDisk": {
              "storageAccountType": "[parameters('osDiskType')]"
            }
          }
        },
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
      "condition": "[equals(parameters('osImageName'), 'UbuntuServer_16.04')]",
      "apiVersion": "2018-06-01",
      "dependsOn": [
        "[parameters('vmName')]"
      ],
      "location": "[parameters('location')]",
      "name": "[concat(parameters('vmName'), '/validate')]",
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
    }{{WriteLinkedTemplatesForExtensions}}
