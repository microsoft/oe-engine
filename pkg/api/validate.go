package api

import (
	"fmt"
	"regexp"
	"strings"

	"github.com/Microsoft/oe-engine/pkg/api/common"
	validator "gopkg.in/go-playground/validator.v9"
)

var (
	validate        *validator.Validate
	keyvaultIDRegex *regexp.Regexp
	labelValueRegex *regexp.Regexp
	labelKeyRegex   *regexp.Regexp
)

const (
	labelKeyPrefixMaxLength = 253
	labelValueFormat        = "^([A-Za-z0-9][-A-Za-z0-9_.]{0,61})?[A-Za-z0-9]$"
	labelKeyFormat          = "^(([a-zA-Z0-9-]+[.])*[a-zA-Z0-9-]+[/])?([A-Za-z0-9][-A-Za-z0-9_.]{0,61})?[A-Za-z0-9]$"
)

func init() {
	validate = validator.New()
	keyvaultIDRegex = regexp.MustCompile(`^/subscriptions/\S+/resourceGroups/\S+/providers/Microsoft.KeyVault/vaults/[^/\s]+$`)
	labelValueRegex = regexp.MustCompile(labelValueFormat)
	labelKeyRegex = regexp.MustCompile(labelKeyFormat)
}

// Validate implements APIObject
func (a *Properties) Validate(isUpdate bool) error {
	if e := validate.Struct(a); e != nil {
		return handleValidationErrors(e.(validator.ValidationErrors))
	}
	if e := a.validateVMPoolProfiles(); e != nil {
		return e
	}
	if e := a.validateVnetProfile(); e != nil {
		return e
	}
	if e := a.validateDiagnosticsProfile(); e != nil {
		return e
	}
	return nil
}

func handleValidationErrors(e validator.ValidationErrors) error {
	// Override any version specific validation error message
	// common.HandleValidationErrors if the validation error message is general
	return common.HandleValidationErrors(e)
}

func (a *Properties) validateVMPoolProfiles() error {
	var hasLinux, hasWindows bool
	names := map[string]bool{}
	for _, p := range a.VMProfiles {
		if names[p.Name] {
			return fmt.Errorf("Duplicated VM pool name %s", p.Name)
		}
		names[p.Name] = true

		if len(p.OSImageName) == 0 {
			return fmt.Errorf("OS image is not specified")
		}
		switch p.OSImageName {
		case OsUbuntu1604:
			hasLinux = true
		case OsWindows2016:
			hasWindows = true
		default:
			return fmt.Errorf("OS image '%s' is not supported", p.OSImageName)
		}
		if len(p.OSDiskType) > 0 {
			found := false
			for _, t := range AllowedOsDiskTypes {
				if t == p.OSDiskType {
					found = true
					break
				}
			}
			if !found {
				return fmt.Errorf("OS disk type '%s' is not included in supported [%s]", p.OSDiskType, strings.Join(AllowedOsDiskTypes, ","))
			}
		}
	}
	if hasLinux {
		if e := a.validateLinuxProfile(); e != nil {
			return e
		}
	}
	if hasWindows {
		if e := a.validateWindowsProfile(); e != nil {
			return e
		}
	}
	return nil
}

func (a *Properties) validateLinuxProfile() error {
	if a.LinuxProfile == nil {
		return fmt.Errorf("LinuxProfile cannot be empty")
	}
	if len(a.LinuxProfile.AdminUsername) == 0 {
		return fmt.Errorf("LinuxProfile.AdminUsername cannot be empty")
	}
	if len(a.LinuxProfile.AdminPassword) > 0 && len(a.LinuxProfile.SSHPubKeys) > 0 {
		return fmt.Errorf("AdminPassword and SSH public keys are mutually exclusive")
	}
	if len(a.LinuxProfile.AdminPassword) == 0 && len(a.LinuxProfile.SSHPubKeys) == 0 {
		return fmt.Errorf("Must specify either AdminPassword or SSH public keys")
	}
	for i, key := range a.LinuxProfile.SSHPubKeys {
		if key == nil || len(key.KeyData) == 0 {
			return fmt.Errorf("SSH public key #%d cannot be empty", i)
		}
	}
	return nil
}

func (a *Properties) validateWindowsProfile() error {
	if a.WindowsProfile == nil {
		return fmt.Errorf("WindowsProfile cannot be empty")
	}
	if e := validate.Var(a.WindowsProfile.AdminUsername, "required"); e != nil {
		return fmt.Errorf("WindowsProfile.AdminUsername cannot be empty")
	}
	if e := validate.Var(a.WindowsProfile.AdminPassword, "required"); e != nil {
		return fmt.Errorf("WindowsProfile.AdminPassword cannot be empty")
	}
	return nil
}

func (a *Properties) validateDiagnosticsProfile() error {
	if a.DiagnosticsProfile == nil || !a.DiagnosticsProfile.Enabled {
		return nil
	}
	if len(a.DiagnosticsProfile.StorageAccountName) == 0 {
		return fmt.Errorf("DiagnosticsProfile.StorageAccountName cannot be empty string")
	}
	return nil
}

func (a *Properties) validateVnetProfile() error {
	p := a.VnetProfile
	if p == nil {
		return nil
	}
	// existing vnet is uniquely defined by resource group, vnet name, and subnet name
	if len(p.VnetResourceGroup) > 0 {
		if len(p.VnetName) == 0 {
			return fmt.Errorf("vnetProfile.vnetName cannot be empty for existing vnet")
		}
		if len(p.SubnetName) == 0 {
			return fmt.Errorf("vnetProfile.subnetName cannot be empty for existing vnet")
		}
		if len(p.VnetAddress) > 0 {
			return fmt.Errorf("vnetProfile.VnetResourceGroup and vnetProfile.vnetAddress are mutually exclusive")
		}
		if len(p.SubnetAddress) > 0 {
			return fmt.Errorf("vnetProfile.VnetResourceGroup and vnetProfile.subnetAddress are mutually exclusive")
		}
	}
	return nil
}

func validateUniquePorts(ports []int, name string) error {
	portMap := make(map[int]bool)
	for _, port := range ports {
		if _, ok := portMap[port]; ok {
			return fmt.Errorf("VM profile '%s' has duplicate port '%d', ports must be unique", name, port)
		}
		portMap[port] = true
	}
	return nil
}
