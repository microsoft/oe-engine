    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      {{GetAllowedLocations}}
      "metadata": {
        "description": "Sets the location for all resources in the cluster"
      }
    },
    "authenticationType": {
      "type": "string",
      "defaultValue": "password",
      "allowedValues": [
        "password",
        "sshPublicKey"
      ],
      "metadata": {
        "description": "Type of authentication to use on Linux virtual machine."
      }
    },
    "LinuxAdminUsername": {
      "type": "string",
      "defaultValue": "azureuser",
      "metadata": {
        "description": "User name for the Linux Virtual Machines."
      }
    },
    "LinuxAdminPasswordOrKey": {
      "type": "securestring",
      "defaultValue": "",
      "metadata": {
        "description": "Linux password or ssh key value."
      }
    },
    "WindowsAdminUsername": {
      "type": "string",
      "defaultValue": "azureuser",
      "metadata": {
        "description": "User name for the Windows Virtual Machines."
      }
    },
    "WindowsAdminPassword": {
      "type": "securestring",
      "defaultValue": "",
      "metadata": {
        "description": "Windows password."
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
      "defaultValue": "{{.VnetProfile.VnetAddress}}",
      "metadata": {
        "description": "VNET address space"
      }
    },
    "subnetName": {
      "type": "string",
      "defaultValue": "[concat(resourceGroup().name, '-subnet')]",
      "metadata": {
        "description": "Name of the subnet."
      }
    },
    "subnetAddress": {
      "type": "string",
      "defaultValue": "{{.VnetProfile.SubnetAddress}}",
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
