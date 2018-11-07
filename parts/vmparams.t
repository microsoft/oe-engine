    
    "{{.Name}}VMSize": {
      "type": "string",
      {{GetAllowedVMSizes}}
      "metadata": {
        "description": "The size of the Virtual Machine."
      }
    },
    "{{.Name}}OSType": {
      "type": "string",
      "allowedValues": [
        "Linux",
        "Windows"
      ],
      "metadata": {
        "description": "OS type"
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
