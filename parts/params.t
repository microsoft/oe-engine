    "location": {
      "defaultValue": "[resourceGroup().location]",
      {{GetAllowedLocations}}
      "metadata": {
        "description": "Sets the location for all resources in the cluster"
      },
      "type": "string"
    },
    "vmName": {
      "metadata": {
        "description": "The name of the Virtual Machine."
      },
      "type": "string"
    },
    "vmSize": {
      {{GetAllowedVMSizes}}
      "metadata": {
        "description": "The size of the Virtual Machine."
      },
      "type": "string"
    },
    "adminUsername": {
      "metadata": {
        "description": "User name for the Virtual Machines (SSH or Password)."
      },
      "type": "string"
    },
    "authenticationType": {
      "type": "string",
      "defaultValue": "password",
      "allowedValues": [
        "password",
        "sshPublicKey"
      ],
      "metadata": {
        "description": "Type of authentication to use on the virtual machine."
      }
    },
    "adminPasswordOrKey": {
      "type": "securestring",
      "metadata": {
        "description": "Password or ssh key value."
      }
    },
    "vnetNewOrExisting": {
      "type": "string",
      "defaultValue": "new",
      "allowedValues": [
        "new",
        "existing"
      ],
      "metadata": {
        "description": "Determines whether or not a new virtual network should be provisioned"
      }
    },
    "vnetName": {
      "type": "string",
      "defaultValue": "[concat(resourceGroup().name, '-vnet')]",
      "metadata": {
        "description": "Name of the virtual network (alphanumeric, hyphen, underscore, period)."
      },
      "minLength": 2,
      "maxLength": 64
    },
    "vnetResourceGroupName": {
      "type": "string",
      "defaultValue": "[resourceGroup().name]",
      "metadata": {
        "description": "Name of the resource group for the existing virtual network."
      }
    },
    "vnetAddress": {
      "type": "string",
      "defaultValue": "{{.MasterProfile.VnetAddress}}",
      "metadata": {
        "description": "VNET address space"
      }
    },
    "subnetName": {
      "type": "string",
      "defaultValue": "[concat(parameters('vmName'), '-subnet')]",
      "metadata": {
        "description": "Name of the subnet."
      }
    },
    "subnetAddress": {
      "type": "string",
      "defaultValue": "{{.MasterProfile.SubnetAddress}}",
      "metadata": {
        "description": "Sets the subnet of the VM."
      }
    },
    "publicInboundPorts": {
      "type": "string",
      "defaultValue": "disable",
      "allowedValues": [
        "enable",
        "disable"
      ],
      "metadata": {
        "description": "Determines whether inbound SSH/RDP connection is enabled in NSG"
      }
    },
    "osImageName": {
      {{GetOSImageNames}}
      "metadata": {
        "description": "OS image name"
      },
      "type": "string"
    },
    "osDiskType": {
      {{GetOsDiskTypes}}
      "metadata": {
        "description": "Type of managed disk to create"
      },
      "type": "string"
    },
    "oeSDKIncluded": {
      "type": "string",
      "defaultValue": "yes",
      "allowedValues": [
        "yes",
        "no"
      ],
      "metadata": {
        "description": "Flag to install OE SDK."
      }
    },
    "bootDiagnostics": {
      "type": "string",
      "defaultValue": "enable",
      "allowedValues": [
        "enable",
        "disable"
      ],
      "metadata": {
        "description": "Type of authentication to use on the virtual machine."
      }
    },
    "diagnosticsStorageAccountNewOrExisting": {
      "type": "string",
      "defaultValue": "new",
      "allowedValues": [
        "new",
        "existing"
      ],
      "metadata": {
        "description": "Determines whether or not a new storage account should be provisioned."
      }
    },
    "diagnosticsStorageAccountName": {
      "type": "string",
      "defaultValue": "none",
      "metadata": {
        "description": "Name of the storage account for diagnostics data."
      }
    },
    "diagnosticsStorageAccountType": {
      "type": "string",
      "defaultValue": "Standard_LRS",
      "allowedValues": [
        "Standard_LRS",
        "Standard_GRS"
      ],
      "metadata": {
        "description": "Type of storage account."
      }
    },
    "diagnosticsStorageAccountKind": {
      "type": "string",
      "defaultValue": "Storage",
      "allowedValues": [
        "Storage",
        "StorageV2"
      ],
      "metadata": {
        "description": "Type of storage account."
      }
    },
    "diagnosticsStorageAccountResourceGroupName": {
      "type": "string",
      "defaultValue": "[resourceGroup().name]",
      "metadata": {
        "description": "Name of the resource group for the existing diagnostics storage account."
      }
    }
{{if .IsLinux}}{{if .LinuxProfile.HasSecrets}}
  {{range  $vIndex, $vault := .LinuxProfile.Secrets}}
    ,
    "linuxKeyVaultID{{$vIndex}}": {
      "metadata": {
        "description": "KeyVaultId{{$vIndex}} to install certificates from on linux machines."
      },
      "type": "string"
    }
    {{range $cIndex, $cert := $vault.VaultCertificates}}
      ,
      "linuxKeyVaultID{{$vIndex}}CertificateURL{{$cIndex}}": {
        "metadata": {
          "description": "CertificateURL{{$cIndex}} to install from KeyVaultId{{$vIndex}} on linux machines."
        },
        "type": "string"
      }
    {{end}}
  {{end}}
{{end}}{{end}}
{{if .IsWindows}}
{{if HasWindowsCustomImage}}
    ,
    "windowsImageSourceUrl": {
      "defaultValue": "",
      "metadata": {
        "description": "The source of the generalized blob which will be used to create a custom windows image."
      },
      "type": "string"
    }
{{end}}
{{if .WindowsProfile.HasSecrets}}
  {{range  $vIndex, $vault := .WindowsProfile.Secrets}}
    ,
    "windowsKeyVaultID{{$vIndex}}": {
      "metadata": {
        "description": "KeyVaultId{{$vIndex}} to install certificates from on windows machines."
      },
      "type": "string"
    }
    {{range $cIndex, $cert := $vault.VaultCertificates}}
      ,
      "windowsKeyVaultID{{$vIndex}}CertificateURL{{$cIndex}}": {
        "metadata": {
          "description": "Url to retrieve Certificate{{$cIndex}} from KeyVaultId{{$vIndex}} to install on windows machines."
        },
        "type": "string"
      },
      "windowsKeyVaultID{{$vIndex}}CertificateStore{{$cIndex}}": {
        "metadata": {
          "description": "CertificateStore to install Certificate{{$cIndex}} from KeyVaultId{{$vIndex}} on windows machines."
        },
        "type": "string"
      }
    {{end}}
  {{end}}
{{end}}
{{end}}
