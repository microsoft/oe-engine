    "adminUsername": "[parameters('adminUsername')]",
    "targetEnvironment": "[parameters('targetEnvironment')]",
    "maxVMsPerPool": 100,
    "apiVersionDefault": "2018-06-01",
    "singleQuote": "'",
    "doubleSingleQuote": "''",
{{if .LinuxProfile.HasSecrets}}
    "linuxProfileSecrets" :
      [
          {{range  $vIndex, $vault := .LinuxProfile.Secrets}}
            {{if $vIndex}} , {{end}}
              {
                "sourceVault":{
                  "id":"[parameters('linuxKeyVaultID{{$vIndex}}')]"
                },
                "vaultCertificates":[
                {{range $cIndex, $cert := $vault.VaultCertificates}}
                  {{if $cIndex}} , {{end}}
                  {
                    "certificateUrl" :"[parameters('linuxKeyVaultID{{$vIndex}}CertificateURL{{$cIndex}}')]"
                  }
                {{end}}
                ]
              }
        {{end}}
      ],
{{end}}
{{if .HasWindows}}
    "windowsAdminUsername": "[parameters('windowsAdminUsername')]",
    "windowsAdminPassword": "[parameters('windowsAdminPassword')]",
{{end}}
    "dnsNamePrefix": "[tolower(parameters('dnsNamePrefix'))]",
    "masterHttpSourceAddressPrefix": "{{.MasterProfile.HTTPSourceAddressPrefix}}",
    "masterLbBackendPoolName": "[concat('acc-pool-', variables('nameSuffix'))]",
    "masterLbID": "[resourceId('Microsoft.Network/loadBalancers',variables('masterLbName'))]",
    "masterLbIPConfigID": "[concat(variables('masterLbID'),'/frontendIPConfigurations/', variables('masterLbIPConfigName'))]",
    "masterLbIPConfigName": "[concat('acc-lbFrontEnd-', variables('nameSuffix'))]",
    "masterLbName": "[concat('acc-lb-', variables('nameSuffix'))]",
    "masterNSGID": "[resourceId('Microsoft.Network/networkSecurityGroups',variables('masterNSGName'))]",
    "masterNSGName": "[concat('acc-nsg-', variables('nameSuffix'))]",
    "masterPublicIPAddressName": "[concat('acc-ip-', variables('dnsNamePrefix'), '-', variables('nameSuffix'))]",
{{if .MasterProfile.IsCustomVNET}}
    "vnetSubnetID": "[parameters('vnetSubnetID')]",
{{else}}
    "subnet": "[parameters('subnet')]",
    "subnetName": "accSubnet",
    "vnetID": "[resourceId('Microsoft.Network/virtualNetworks',variables('virtualNetworkName'))]",
    "vnetSubnetID": "[concat(variables('vnetID'),'/subnets/',variables('subnetName'))]",
    "virtualNetworkName": "[concat('acc-vnet-', variables('nameSuffix'))]",
{{end}}
    "staticIP": "[parameters('staticIP')]",
    "vmName": "[concat('acc-', variables('nameSuffix'))]",
    "vmSize": "[parameters('vmSize')]",
    "nameSuffix": "[parameters('nameSuffix')]",
    {{GetOSImageReferences}}
    "sshKeyPath": "[concat('/home/', variables('adminUsername'), '/.ssh/authorized_keys')]",
    "sshRSAPublicKey": "[parameters('sshRSAPublicKey')]",
    "locations": [
         "[resourceGroup().location]",
         "[parameters('location')]"
    ],
    "location": "[variables('locations')[mod(add(2,length(parameters('location'))),add(1,length(parameters('location'))))]]"
