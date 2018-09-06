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
    "apiVersionStorage": "2015-06-15",

    "storageAccountBaseName": "[uniqueString(concat(variables('dnsNamePrefix'),variables('location')))]",
    "masterStorageAccountExhibitorName": "[concat(variables('storageAccountBaseName'), 'exhb0')]",
    "storageAccountType": "Standard_LRS",
{{if .HasStorageAccountDisks}}
    "maxVMsPerStorageAccount": 20,
    "maxStorageAccountsPerAgent": "[div(variables('maxVMsPerPool'),variables('maxVMsPerStorageAccount'))]",
    "dataStorageAccountPrefixSeed": 97,
    "storageAccountPrefixes": [ "0", "6", "c", "i", "o", "u", "1", "7", "d", "j", "p", "v", "2", "8", "e", "k", "q", "w", "3", "9", "f", "l", "r", "x", "4", "a", "g", "m", "s", "y", "5", "b", "h", "n", "t", "z" ],
    "storageAccountPrefixesCount": "[length(variables('storageAccountPrefixes'))]",
    {{GetSizeMap}},
{{else}}
    "storageAccountPrefixes": [],
{{end}}
{{if .MasterProfile.IsStorageAccount}}
    "masterStorageAccountName": "[concat(variables('storageAccountBaseName'), 'mstr0')]",
{{end}}
{{if .MasterProfile.IsCustomVNET}}
    "vnetSubnetID": "[parameters('vnetSubnetID')]",
{{else}}
    "subnet": "[parameters('subnet')]",
    "subnetName": "accSubnet",
    "vnetID": "[resourceId('Microsoft.Network/virtualNetworks',variables('virtualNetworkName'))]",
    "vnetSubnetID": "[concat(variables('vnetID'),'/subnets/',variables('subnetName'))]",
    "virtualNetworkName": "[concat('acc-vnet-', variables('nameSuffix'))]",
{{end}}
    "staticIP": "[(parameters('staticIP')]",
    "masterVMNamePrefix": "[concat('acc-', variables('nameSuffix'), '-')]",
    "masterVMNic": [
      "[concat(variables('masterVMNamePrefix'), 'nic-0')]",
      "[concat(variables('masterVMNamePrefix'), 'nic-1')]",
      "[concat(variables('masterVMNamePrefix'), 'nic-2')]",
      "[concat(variables('masterVMNamePrefix'), 'nic-3')]",
      "[concat(variables('masterVMNamePrefix'), 'nic-4')]",
      "[concat(variables('masterVMNamePrefix'), 'nic-5')]",
      "[concat(variables('masterVMNamePrefix'), 'nic-6')]"
    ],
    "vmSize": "[parameters('vmSize')]",
    "nameSuffix": "[parameters('nameSuffix')]",
    "osImageOffer": "[parameters('osImageOffer')]",
    "osImagePublisher": "[parameters('osImagePublisher')]",
    "osImageSKU": "[parameters('osImageSKU')]",
    "osImageVersion": "[parameters('osImageVersion')]",
    "sshKeyPath": "[concat('/home/', variables('adminUsername'), '/.ssh/authorized_keys')]",
    "sshRSAPublicKey": "[parameters('sshRSAPublicKey')]",
    "locations": [
         "[resourceGroup().location]",
         "[parameters('location')]"
    ],
    "location": "[variables('locations')[mod(add(2,length(parameters('location'))),add(1,length(parameters('location'))))]]",
    "masterSshInboundNatRuleIdPrefix": "[concat(variables('masterLbID'),'/inboundNatRules/SSH-',variables('masterVMNamePrefix'))]",
    "masterLbInboundNatRules": [
            [
                {
                    "id": "[concat(variables('masterSshInboundNatRuleIdPrefix'),'0')]"
                }
            ],
            [
                {
                    "id": "[concat(variables('masterSshInboundNatRuleIdPrefix'),'1')]"
                }
            ],
            [
                {
                    "id": "[concat(variables('masterSshInboundNatRuleIdPrefix'),'2')]"
                }
            ],
            [
                {
                    "id": "[concat(variables('masterSshInboundNatRuleIdPrefix'),'3')]"
                }
            ],
            [
                {
                    "id": "[concat(variables('masterSshInboundNatRuleIdPrefix'),'4')]"
                }
            ]
        ]
