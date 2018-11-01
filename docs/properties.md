# Setting properties in the VM definition file

This document describes VM properties, configurable in the VM definition file

### VM name
Specifies VM name.

* Path: `properties/vmProfiles[]/name`
* Value: string (follows the rules of underlying OS)

### OS image
Specifies the type and the version of the operating system.

* Path: `properties/vmProfiles[]/osImageName`
* Values:
    * `UbuntuServer_16.04`
    * `WindowsServer_2016`

### OS disk type
Specifies OS disk characteristics.

* Path: `properties/vmProfiles[]/osImageName`
* Values:
    * `Premium_LRS` - Premium SSD
    * `StandardSSD_LRS` - Standard SSD
    * `Standard_LRS` - Standard HDD

### VM compute power
Specifies VM compute characteristics

* Path: `properties/vmProfiles[]/vmSize`
* Values:
    * `Standard_DC2s`
    * `Standard_DC4s`

Refer to the [VM sizes in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes) for more details.

### VM Software
Indicates whether Open Enclave SDK and its dependencies should be installed or not.

* Path: `properties/vmProfiles[]/isVanilla`
* Values: boolean
    * `true` - a vanilla VM. Open Enclave SDK will not be installed
    * `false` - not a vanilla VM. Open Enclave SDK will be installed and verified

### Linux credentials
If at least one of the VMs runs Linux, `linuxProfile` must be present and contain admin user name and password or public SSH key.
Multiple public keys are **supported**.
Setting both the password and the public key(s) is **not allowed**.

* Path: `properties/linuxProfile/adminUsername`
* Value: string

* Path: `properties/linuxProfile/adminPassword`
* Value: string

* Path: `properties/linuxProfile/sshPublicKeys[]/keyData`
* Value: public SSH key

The public SSH key(s) could also be set from the command line using `--ssh-public-key` argument.
```
oe-engine generate oe-vm.json --ssh-public-key .ssh/id_rsa1.pub --ssh-public-key .ssh/id_rsa2.pub ...
```

### Windows credentials
If at least one of the VMs runs Windows, `windowsProfile` must be present and contain admin user name and password.

* Path: `properties/windowsProfile/adminUsername`
* Value: string

* Path: `properties/windowsProfile/adminPassword`
* Value: string
