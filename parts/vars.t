    "adminUsername": "[parameters('adminUsername')]",
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
    "masterHttpSourceAddressPrefix": "{{.MasterProfile.HTTPSourceAddressPrefix}}",
    "masterLbBackendPoolName": "acc-pool",
    "masterLbID": "[resourceId('Microsoft.Network/loadBalancers',variables('masterLbName'))]",
    "masterLbIPConfigID": "[concat(variables('masterLbID'),'/frontendIPConfigurations/', variables('masterLbIPConfigName'))]",
    "masterLbIPConfigName": "acc-lbFrontEnd",
    "masterLbName": "acc-lb",
    "masterNSGID": "[resourceId('Microsoft.Network/networkSecurityGroups',variables('masterNSGName'))]",
    "masterNSGName": "acc-nsg",
    "masterPublicIPAddressName": "acc-ip",
{{if .MasterProfile.IsCustomVNET}}
    "vnetSubnetID": "[parameters('vnetSubnetID')]",
{{else}}
    "subnet": "[parameters('subnet')]",
    "subnetName": "accSubnet",
    "vnetID": "[resourceId('Microsoft.Network/virtualNetworks',variables('virtualNetworkName'))]",
    "vnetSubnetID": "[concat(variables('vnetID'),'/subnets/',variables('subnetName'))]",
    "virtualNetworkName": "acc-vnet",
{{end}}
    "staticIP": "[parameters('staticIP')]",
    {{GetOSImageReferences}}
    "location": "[parameters('location')]",
    "linuxConfiguration": {
      "disablePasswordAuthentication": "true",
      "ssh": {
        "publicKeys": [
          {
            "keyData": "[parameters('adminPasswordOrKey')]",
            "path": "[concat('/home/', parameters('adminUsername'), '/.ssh/authorized_keys')]"
          }
        ]
      }
    },
    "windowsConfiguration": {
      "provisionVmAgent": "true"
    }
