    "adminUsername": "[parameters('adminUsername')]",
    "maxVMsPerPool": 100,
    "apiVersionDefault": "2018-06-01",
    "apiVersionStorage": "2018-02-01",
    "singleQuote": "'",
    "doubleSingleQuote": "''",
{{if .IsLinux}}{{if .LinuxProfile.HasSecrets}}
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
{{end}}{{end}}
    "nsgID": "[resourceId('Microsoft.Network/networkSecurityGroups',parameters('nsgName'))]",
    "vnetSubnetID": "[resourceId(parameters('vnetResourceGroupName'), 'Microsoft.Network/virtualNetworks/subnets/', parameters('vnetName'), parameters('subnetName'))]",
    {{GetOSImageReferences}},
    {{GetVMPlans}},
    "plan": "[variables('plans')[parameters('osImageName')]]",
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
    },
    "linuxExtensionProperties": {
      "publisher": "Microsoft.OSTCExtensions",
      "type": "CustomScriptForLinux",
      "typeHandlerVersion": "1.4",
      "autoUpgradeMinorVersion": true,
      "settings": {
        "commandToExecute": "[variables('linuxExtCommand')]"
      }
    },
    "windowsExtensionProperties": {
      "publisher": "Microsoft.Compute",
      "type": "CustomScriptExtension",
      "typeHandlerVersion": "1.8",
      "autoUpgradeMinorVersion": true,
      "settings": {
          "commandToExecute": "exit 0"
      }
    },
    "linuxSecurityRules": [
      {
        "properties": {
          "priority": 200,
          "access": "Allow",
          "direction": "Inbound",
          "destinationPortRange": "22",
          "sourcePortRange": "*",
          "destinationAddressPrefix": "*",
          "protocol": "Tcp",
          "description": "Allow SSH",
          "sourceAddressPrefix": "*"
        },
        "name": "ssh"
      }
    ],
    "windowsSecurityRules": [
      {
        "properties": {
          "priority": 200,
          "access": "Allow",
          "direction": "Inbound",
          "destinationPortRange": "3389",
          "sourcePortRange": "*",
          "destinationAddressPrefix": "*",
          "protocol": "Tcp",
          "description": "Allow RDP",
          "sourceAddressPrefix": "*"
        },
        "name": "rdp"
      }
    ],
    "securityRules": "[if(equals(parameters('osImageName'), 'WindowsServer_2016'), variables('windowsSecurityRules'), variables('linuxSecurityRules'))]",
    "diagnosticsProfile": {
      "bootDiagnostics": {
        "enabled": true,
        "storageUri": "[concat('https://', parameters('diagnosticsStorageAccountName'), '.blob.core.windows.net/')]"
      }
    },
    "linuxExtCommand": "[if(equals(parameters('oeSDKIncluded'), 'yes'), '/bin/bash -c \"secs=600; SECONDS=0; while (( SECONDS < secs )); do if [ -e /opt/azure/acc/completed ]; then /opt/azure/acc/validate.sh; exit $? ; fi; echo waiting for validation; sleep 20; done; echo validation timeout; exit 1;\"', '/bin/bash -c \"exit 0\"')]"
