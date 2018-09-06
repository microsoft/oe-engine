{{if .MasterProfile.IsStorageAccount}}
    {
      "apiVersion": "[variables('apiVersionStorage')]",
      "dependsOn": [
        "[concat('Microsoft.Network/publicIPAddresses/', variables('masterPublicIPAddressName'))]"
      ],
      "location": "[variables('location')]",
      "name": "[variables('masterStorageAccountName')]",
      "properties": {
        "accountType": "[variables('vmSizesMap')[variables('vmSize')].storageAccountType]"
      },
      "type": "Microsoft.Storage/storageAccounts"
    },
{{end}}
    {
      "apiVersion": "[variables('apiVersionStorage')]",
      "dependsOn": [
        "[concat('Microsoft.Network/publicIPAddresses/', variables('masterPublicIPAddressName'))]"
      ],
      "location": "[variables('location')]",
      "name": "[variables('masterStorageAccountExhibitorName')]",
      "properties": {
        "accountType": "Standard_LRS"
      },
      "type": "Microsoft.Storage/storageAccounts"
    },
{{if not .MasterProfile.IsCustomVNET}}
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "dependsOn": [
          {{GetVNETSubnetDependencies}}
      ],
      "location": "[variables('location')]",
      "name": "[variables('virtualNetworkName')]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            {{GetVNETAddressPrefixes}}
          ]
        },
        "subnets": [
          {{GetVNETSubnets true}}
        ]
      },
      "type": "Microsoft.Network/virtualNetworks"
    },
{{end}}
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "location": "[variables('location')]",
      "name": "[variables('masterPublicIPAddressName')]",
      "properties": {
        "dnsSettings": {
          "domainNameLabel": "[variables('dnsNamePrefix')]"
        },
        "publicIPAllocationMethod": "Dynamic"
      },
      "type": "Microsoft.Network/publicIPAddresses"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "dependsOn": [
        "[concat('Microsoft.Network/publicIPAddresses/', variables('masterPublicIPAddressName'))]"
      ],
      "location": "[variables('location')]",
      "name": "[variables('masterLbName')]",
      "properties": {
        "backendAddressPools": [
          {
            "name": "[variables('masterLbBackendPoolName')]"
          }
        ],
        "frontendIPConfigurations": [
          {
            "name": "[variables('masterLbIPConfigName')]",
            "properties": {
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('masterPublicIPAddressName'))]"
              }
            }
          }
        ]
{{if .MasterProfile.Accessible}}
        ,"loadBalancingRules": [
	        {
            "name": "LBRule443",
            "properties": {
              "frontendIPConfiguration": {
                "id": "[variables('masterLbIPConfigID')]"
              },
              "frontendPort": 443,
              "backendPort": 443,
              "enableFloatingIP": false,
              "idleTimeoutInMinutes": 4,
              "protocol": "Tcp",
              "loadDistribution": "Default",
              "backendAddressPool": {
                "id": "[concat(variables('masterLbID'), '/backendAddressPools/', variables('masterLbBackendPoolName'))]"
              }
            }
          },
          {
            "name": "LBRule80",
            "properties": {
              "frontendIPConfiguration": {
                "id": "[variables('masterLbIPConfigID')]"
              },
              "frontendPort": 80,
              "backendPort": 80,
              "enableFloatingIP": false,
              "idleTimeoutInMinutes": 4,
              "protocol": "Tcp",
              "loadDistribution": "Default",
              "backendAddressPool": {
                "id": "[concat(variables('masterLbID'), '/backendAddressPools/', variables('masterLbBackendPoolName'))]"
              }
            }
          }
        ]
{{end}}
      },
      "type": "Microsoft.Network/loadBalancers"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "dependsOn": [
        "[variables('masterLbID')]"
      ],
      "location": "[variables('location')]",
      "name": "[concat(variables('masterLbName'), '/', 'SSH-', variables('masterVMNamePrefix')]",
      "properties": {
        "backendPort": 22,
        "enableFloatingIP": false,
        "frontendIPConfiguration": {
          "id": "[variables('masterLbIPConfigID')]"
        },
        "frontendPort": "22",
        "protocol": "tcp"
      },
      "type": "Microsoft.Network/loadBalancers/inboundNatRules"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "location": "[variables('location')]",
      "name": "[variables('masterNSGName')]",
      "properties": {
        "securityRules": [
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
        ]
      },
      "type": "Microsoft.Network/networkSecurityGroups"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "dependsOn": [
        "[variables('masterNSGID')]",
{{if not .MasterProfile.IsCustomVNET}}
        "[variables('vnetID')]",
{{end}}
        "[variables('masterLbID')]",
        "[concat(variables('masterLbID'),'/inboundNatRules/SSH-',variables('masterVMNamePrefix'))]"
      ],
      "location": "[variables('location')]",
      "name": "[concat(variables('masterVMNamePrefix'), 'nic')]",
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipConfigNode",
            "properties": {
              "loadBalancerBackendAddressPools": [
                {
                  "id": "[concat(variables('masterLbID'), '/backendAddressPools/', variables('masterLbBackendPoolName'))]"
                }
              ],
              "loadBalancerInboundNatRules": [
                {
                  "id": "[concat(variables('masterLbID'),'/inboundNatRules/SSH-',variables('masterVMNamePrefix'))]"
                }
              ],
              "privateIPAddress": "[variables('staticIP')]",
              "privateIPAllocationMethod": "Static",
              "subnet": {
                "id": "[variables('vnetSubnetID')]"
              }
            }
          }
        ]
        ,"networkSecurityGroup": {
          "id": "[variables('masterNSGID')]"
        }
      },
      "type": "Microsoft.Network/networkInterfaces"
    },
    {
      "apiVersion": "[variables('apiVersionDefault')]",
      "dependsOn": [
        "[concat('Microsoft.Network/networkInterfaces/', variables('masterVMNamePrefix'), 'nic')]",
{{if .MasterProfile.IsStorageAccount}}
        "[variables('masterStorageAccountName')]",
{{end}}
        "[variables('masterStorageAccountExhibitorName')]"
      ],
      "tags":
      {
        "creationSource" : "[concat('oe-engine-', variables('masterVMNamePrefix'))]"
      },
      "location": "[variables('location')]",
      "name": "[concat(variables('masterVMNamePrefix'))]",
      "plan": {
          "name": "[parameters('osImageSKU')]",
          "publisher": "[variables('osImagePublisher')]",
          "product": "[variables('osImageOffer')]"
        },
      "properties": {
        "hardwareProfile": {
          "vmSize": "[variables('vmSize')]"
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces',concat(variables('masterVMNamePrefix'), 'nic'))]"
            }
          ]
        },
        "osProfile": {
          "adminUsername": "[variables('adminUsername')]",
          "computername": "[concat(variables('masterVMNamePrefix'))]",
          {{GetCustomData}}
          "linuxConfiguration": {
            "disablePasswordAuthentication": "true",
            "ssh": {
                "publicKeys": [
                    {
                        "keyData": "[variables('sshRSAPublicKey')]",
                        "path": "[variables('sshKeyPath')]"
                    }
                ]
            }
          }
          {{if .LinuxProfile.HasSecrets}}
          ,
          "secrets": "[variables('linuxProfileSecrets')]"
          {{end}}
        },
        "storageProfile": {
          "imageReference": {
            "offer": "[variables('osImageOffer')]",
            "publisher": "[variables('osImagePublisher')]",
            "sku": "[variables('osImageSKU')]",
            "version": "[variables('osImageVersion')]"
          },
          "osDisk": {
            "caching": "ReadWrite"
            ,"createOption": "FromImage"
{{if .MasterProfile.IsStorageAccount}}
            ,"name": "[concat(variables('masterVMNamePrefix'),'-osdisk')]"
            ,"vhd": {
              "uri": "[concat(reference(concat('Microsoft.Storage/storageAccounts/',variables('masterStorageAccountName')),variables('apiVersionStorage')).primaryEndpoints.blob,'vhds/',variables('masterVMNamePrefix'),'-osdisk.vhd')]"
            }
{{end}}
{{if ne .MasterProfile.OSDiskSizeGB 0}}
            ,"diskSizeGB": {{.MasterProfile.OSDiskSizeGB}}
{{end}}
          }
        }
      },
      "type": "Microsoft.Compute/virtualMachines"
    }
