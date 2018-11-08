    
    "{{.Name}}PublicIPAddressName": "[concat('{{.Name}}', '-ip')]",
    "{{.Name}}NSGName": "[concat('{{.Name}}', '-nsg')]",
    "{{.Name}}NSGID": "[resourceId('Microsoft.Network/networkSecurityGroups',variables('{{.Name}}NSGName'))]",
{{if IsLinux .}}
    "{{.Name}}OSProfile": {
      "computername": "{{.Name}}",
      "adminUsername": "[parameters('linuxAdminUsername')]",
      "adminPassword": "[parameters('linuxAdminPassword')]",
      "customData": "[if(equals(parameters('{{.Name}}IsVanilla'), 'true'), json('null'), {{GetLinuxCustomData}})]",
      "linuxConfiguration": "[if(equals(parameters('authenticationType'), 'password'), json('null'), variables('linuxConfiguration'))]"
    },
    "{{.Name}}StorageProfile": {
      "imageReference": {
{{if HasLinuxCustomImage}}
        "id": "[resourceId('Microsoft.Compute/images','CustomLinuxImage')]"
{{else}}
        "publisher": "[parameters('linuxImagePublisher')]",
        "offer": "[parameters('linuxImageOffer')]",
        "sku": "[parameters('linuxImageSKU')]",
        "version": "[parameters('linuxImageVersion')]"
{{end}}
      },
      "osDisk": {
        "caching": "ReadWrite",
        "createOption": "FromImage",
        "managedDisk": {
          "storageAccountType": "[parameters('{{.Name}}OSDiskType')]"
        }
      }
    },
{{end}}
{{if IsWindows .}}
    "{{.Name}}OSProfile": {
      "computername": "{{.Name}}",
      "adminUsername": "[parameters('windowsAdminUsername')]",
      "adminPassword": "[parameters('windowsAdminPassword')]",
      "customData": "{{GetWindowsCustomData .}}",
      "windowsConfiguration": "[variables('windowsConfiguration')]"
    },    
    "{{.Name}}StorageProfile": {
      "imageReference": {
{{if HasWindowsCustomImage}}
        "id": "[resourceId('Microsoft.Compute/images','CustomWindowsImage')]"
{{else}}
        "publisher": "[parameters('windowsImagePublisher')]",
        "offer": "[parameters('windowsImageOffer')]",
        "sku": "[parameters('windowsImageSKU')]",
        "version": "[parameters('windowsImageVersion')]"
{{end}}
      },
      "osDisk": {
        "caching": "ReadWrite",
        "createOption": "FromImage",
        "managedDisk": {
          "storageAccountType": "[parameters('{{.Name}}OSDiskType')]"
        }
      }
    },
{{end}}
