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
  {{if .MasterProfile.IsCustomVNET}}
    "vnetSubnetID": {
      "metadata": {
        "description": "Sets the vnet subnet of the VM."
      },
      "type": "string"
    },
  {{else}}
    "subnet": {
      "defaultValue": "{{.MasterProfile.Subnet}}",
      "metadata": {
        "description": "Sets the subnet of the VM."
      },
      "type": "string"
    },
  {{end}}
    "staticIP": {
      "defaultValue": "{{.MasterProfile.StaticIP}}",
      "metadata": {
        "description": "Sets the static IP of the VM"
      },
      "type": "string"
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
    "storageAccountType": {
      {{GetStorageAccountTypes}}
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
