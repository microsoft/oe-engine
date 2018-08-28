package common

import (
	"fmt"

	validator "gopkg.in/go-playground/validator.v9"
)

// HandleValidationErrors is the helper function to catch validator.ValidationError
// based on Namespace of the error, and return customized error message.
func HandleValidationErrors(e validator.ValidationErrors) error {
	err := e[0]
	ns := err.Namespace()
	switch ns {
	case "Properties.MasterProfile", "Properties.MasterProfile.DNSPrefix", "Properties.MasterProfile.VMSize",
		"Properties.LinuxProfile", "Properties.ServicePrincipalProfile.ClientID",
		"Properties.WindowsProfile.AdminUsername",
		"Properties.WindowsProfile.AdminPassword":
		return fmt.Errorf("missing %s", ns)
	case "Properties.MasterProfile.Count":
		return fmt.Errorf("MasterProfile count needs to be 1, 3, or 5")
	case "Properties.MasterProfile.OSDiskSizeGB":
		return fmt.Errorf("Invalid os disk size of %d specified.  The range of valid values are [%d, %d]", err.Value().(int), MinDiskSizeGB, MaxDiskSizeGB)
	case "Properties.MasterProfile.IPAddressCount":
		return fmt.Errorf("MasterProfile.IPAddressCount needs to be in the range [%d,%d]", MinIPAddressCount, MaxIPAddressCount)
	case "Properties.MasterProfile.StorageProfile":
		return fmt.Errorf("Unknown storageProfile '%s'. Specify either %s or %s", err.Value().(string), StorageAccount, ManagedDisks)
	}
	return fmt.Errorf("Namespace %s is not caught, %+v", ns, e)
}
