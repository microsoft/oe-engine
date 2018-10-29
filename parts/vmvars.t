    
    "{{.Name}}PublicIPAddressName": "[concat('{{.Name}}', '-ip')]",
    "{{.Name}}NSGName": "[concat('{{.Name}}', '-nsg')]",
    "{{.Name}}NSGID": "[resourceId('Microsoft.Network/networkSecurityGroups',variables('{{.Name}}NSGName'))]",
    "{{.Name}}SecurityRules": "[if(equals(parameters('{{.Name}}OSImageName'), 'WindowsServer_2016'), variables('windowsSecurityRules'), variables('linuxSecurityRules'))]",