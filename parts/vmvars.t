    
    "{{.Name}}PublicIPAddressName": "[concat('{{.Name}}', '-ip')]",
    "{{.Name}}NSGName": "[concat('{{.Name}}', '-nsg')]",
    "{{.Name}}NSGID": "[resourceId('Microsoft.Network/networkSecurityGroups',variables('{{.Name}}NSGName'))]",
    "{{.Name}}SecurityRules": "[if(equals(parameters('{{.Name}}OSImageName'), 'WindowsServer_2016'), variables('windowsSecurityRules'), variables('linuxSecurityRules'))]",
    "{{.Name}}LinuxOsProfile": {
      "computername": "{{.Name}}",
      "adminUsername": "[parameters('LinuxAdminUsername')]",
      "adminPassword": "[parameters('LinuxAdminPasswordOrKey')]",
      "customData": "[if(equals(parameters('{{.Name}}IsVanilla'), 'true'), json('null'), {{GetLinuxCustomData}})]",
      "linuxConfiguration": "[if(equals(parameters('authenticationType'), 'password'), json('null'), variables('linuxConfiguration'))]"
    },
    "{{.Name}}WindowsOsProfile": {
      "computername": "{{.Name}}",
      "adminUsername": "[parameters('WindowsAdminUsername')]",
      "adminPassword": "[parameters('WindowsAdminPassword')]",
      "customData": "{{GetWindowsCustomData .}}",
      "windowsConfiguration": "[variables('windowsConfiguration')]"
    },
    "{{.Name}}LinuxStorageProfile": {
      "imageReference": "[variables('imageReference')[parameters('{{.Name}}OSImageName')]]",
      "osDisk": {
        "caching": "ReadWrite",
        "createOption": "FromImage",
        "managedDisk": {
          "storageAccountType": "[parameters('{{.Name}}OSDiskType')]"
        }
      }
    },
    "{{.Name}}WindowsStorageProfile": {
{{if HasWindowsCustomImage}}
      "imageReference": {
        "id": "[resourceId('Microsoft.Compute/images','CustomWindowsImage')]"
      },
{{else}}
      "imageReference": "[variables('imageReference')[parameters('{{.Name}}OSImageName')]]",
{{end}}
      "osDisk": {
        "caching": "ReadWrite",
        "createOption": "FromImage",
        "managedDisk": {
          "storageAccountType": "[parameters('{{.Name}}OSDiskType')]"
        }
      }
    },
