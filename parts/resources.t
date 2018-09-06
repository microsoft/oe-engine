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
      "name": "[concat(variables('masterLbName'), '/', 'SSH-', variables('vmName'))]",
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
        "[concat(variables('masterLbID'),'/inboundNatRules/SSH-',variables('vmName'))]"
      ],
      "location": "[variables('location')]",
      "name": "[concat(variables('vmName'), '-nic')]",
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
                  "id": "[concat(variables('masterLbID'),'/inboundNatRules/SSH-',variables('vmName'))]"
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
        "[concat('Microsoft.Network/networkInterfaces/', variables('vmName'), '-nic')]"
      ],
      "tags":
      {
        "creationSource" : "[concat('oe-engine-', variables('vmName'))]"
      },
      "location": "[variables('location')]",
      "name": "[variables('vmName')]",
      {{GetVMPlan .MasterProfile.OSImageName}}
      "properties": {
        "hardwareProfile": {
          "vmSize": "[variables('vmSize')]"
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces',concat(variables('vmName'), '-nic'))]"
            }
          ]
        },
        "osProfile": {
          "adminUsername": "[variables('adminUsername')]",
          "computername": "[variables('vmName')]",
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
          "imageReference": "[variables('imageReference')[parameters('osImageName')]]",
          "osDisk": {
            "caching": "ReadWrite",
            "createOption": "FromImage",
{{if ne .MasterProfile.OSDiskSizeGB 0}}
            "diskSizeGB": {{.MasterProfile.OSDiskSizeGB}},
{{end}}
            "managedDisk": {
              "storageAccountType": "[parameters('storageAccountType')]"
            }
          }
        }
      },
      "type": "Microsoft.Compute/virtualMachines"
    }
