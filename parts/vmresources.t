    {
      "apiVersion": "2018-06-01",
      "location": "[parameters('location')]",
      "name": "[variables('{{.Name}}PublicIPAddressName')]",
      "properties": {
{{if HasDNSName .}}
        "dnsSettings": {
          "domainNameLabel": "{{.Name}}"
        },
{{end}}
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
        "osProfile": "[variables('{{.Name}}OSProfile')]",
        "storageProfile": "[variables('{{.Name}}StorageProfile')]",
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
      "condition": "[and(equals(parameters('{{.Name}}IsVanilla'), 'false'), equals(parameters('{{.Name}}OSType'), 'Linux'))]",
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
          "commandToExecute": "/bin/bash -c \"secs=600; SECONDS=0; while (( SECONDS < secs )); do if [ -e /opt/azure/acc/completed ]; then if [ $(cat /opt/azure/acc/completed) == ok ]; then /opt/azure/acc/validate.sh; exit $? ; else echo provision failed; exit 1; fi; fi; sleep 20; done; echo validation timeout; exit 1; \""
        }
      },
      "type": "Microsoft.Compute/virtualMachines/extensions"
    },
    {
      "condition": "[equals(parameters('{{.Name}}OSType'), 'Windows')]",
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
