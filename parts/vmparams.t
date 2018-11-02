    
    "{{.Name}}VMSize": {
      "type": "string",
      {{GetAllowedVMSizes}}
      "metadata": {
        "description": "The size of the Virtual Machine."
      }
    },
    "{{.Name}}OSImageName": {
      "type": "string",
      {{GetOSImageNames}}
      "metadata": {
        "description": "OS image name"
      }
    },
    "{{.Name}}OSDiskType": {
      "type": "string",
      {{GetOsDiskTypes}}
      "metadata": {
        "description": "Type of managed disk to create."
      }
    },
    "{{.Name}}IsVanilla": {
      "type": "string",
      "defaultValue": "false",
      "allowedValues": [
        "false",
        "true"
      ],
      "metadata": {
        "description": "Flag to provision vanilla VM or install OE SDK."
      }
    },
    "{{.Name}}HasDNSName": {
      "type": "string",
      "defaultValue": "false",
      "allowedValues": [
        "false",
        "true"
      ],
      "metadata": {
        "description": "Flag to configure VM DNS name."
      }
    },
