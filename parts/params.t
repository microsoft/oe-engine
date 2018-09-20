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
        "description": "Determines whether or not a new virtual network should be provisioned.  Existing virtual networks must have been provisioned in US East. //unless you really need it for the preview, I would just create a new vnet - so the location mismatch doesn't cause problems"
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
    "osImageName": {
      {{GetOSImageNames}}
      "metadata": {
        "description": "OS image name"
      },
      "type": "string"
    },
    "diskSizeGB": {
      "defaultValue": "",
      "metadata": {
        "description": "OS disk size in GB"
      },
      "type": "string"
    },
    "osDiskType": {
      {{GetOsDiskTypes}}
      "metadata": {
        "description": "Type of managed disk to create"
      },
      "type": "string"
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
{{if .IsWindows}}{{if .WindowsProfile.HasSecrets}}
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
{{end}} {{end}}
