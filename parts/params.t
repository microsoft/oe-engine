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
    "linuxAdminUsername": {
      "type": "string",
      "defaultValue": "azureuser",
      "metadata": {
        "description": "User name for the Linux Virtual Machines."
      }
    },
    "linuxAdminPassword": {
      "type": "securestring",
      "defaultValue": "",
      "metadata": {
        "description": "Linux password."
      }
    },
    "linuxImagePublisher": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Linux image publisher."
      }
    },
    "linuxImageOffer": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Linux image offer."
      }
    },
    "linuxImageSKU": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Linux image SKU."
      }
    },
    "linuxImageVersion": {
      "type": "string",
      "defaultValue": "latest",
      "metadata": {
        "description": "Linux image version."
      }
    },
    "linuxImageSourceUrl": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Linux image source URL."
      }
    },
    "windowsImagePublisher": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Windows image publisher."
      }
    },
    "windowsImageOffer": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Windows image offer."
      }
    },
    "windowsImageSKU": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Windows image SKU."
      }
    },
    "windowsImageVersion": {
      "type": "string",
      "defaultValue": "latest",
      "metadata": {
        "description": "Windows image version."
      }
    },
    "windowsImageSourceUrl": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Windows image source URL."
      }
    },
    "windowsAdminUsername": {
      "type": "string",
      "defaultValue": "azureuser",
      "metadata": {
        "description": "User name for the Windows Virtual Machines."
      }
    },
    "windowsAdminPassword": {
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
{{if HasLinuxCustomImage}}
    "linuxImageSourceUrl": {
      "defaultValue": "",
      "metadata": {
        "description": "The source of the generalized blob which will be used to create a custom Linux image."
      },
      "type": "string"
    },
{{end}}
{{if HasWindowsCustomImage}}
    "windowsImageSourceUrl": {
      "defaultValue": "",
      "metadata": {
        "description": "The source of the generalized blob which will be used to create a custom Windows image."
      },
      "type": "string"
    },
{{end}}
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
