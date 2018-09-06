package common

import (
	"fmt"

	validator "gopkg.in/go-playground/validator.v9"
)

const (
	// MinDiskSizeGB specifies the minimum attached disk size
	MinDiskSizeGB = 1
	// MaxDiskSizeGB specifies the maximum attached disk size
	MaxDiskSizeGB = 1023
)

// HandleValidationErrors is the helper function to catch validator.ValidationError
// based on Namespace of the error, and return customized error message.
func HandleValidationErrors(e validator.ValidationErrors) error {
	err := e[0]
	ns := err.Namespace()
	switch ns {
	case "Properties.MasterProfile", "Properties.MasterProfile.DNSPrefix", "Properties.MasterProfile.VMSize",
		"Properties.LinuxProfile",
		"Properties.WindowsProfile.AdminUsername",
		"Properties.WindowsProfile.AdminPassword":
		return fmt.Errorf("missing %s", ns)
	case "Properties.MasterProfile.OSDiskSizeGB":
		return fmt.Errorf("Invalid os disk size of %d specified.  The range of valid values are [%d, %d]", err.Value().(int), MinDiskSizeGB, MaxDiskSizeGB)
	}
	return fmt.Errorf("Namespace %s is not caught, %+v", ns, e)
}
