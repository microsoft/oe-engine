    
    "{{.Name}}VMSize": {
      {{GetAllowedVMSizes}}
      "metadata": {
        "description": "The size of the Virtual Machine."
      },
      "type": "string"
    },
    "{{.Name}}OSImageName": {
      {{GetOSImageNames}}
      "metadata": {
        "description": "OS image name"
      },
      "type": "string"
    },
    "{{.Name}}OSDiskType": {
      {{GetOsDiskTypes}}
      "metadata": {
        "description": "Type of managed disk to create"
      },
      "type": "string"
    },
