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
func (p *Properties) Validate(isUpdate bool) error {
	if e := validate.Struct(p); e != nil {
		return handleValidationErrors(e.(validator.ValidationErrors))
	}
	if e := p.validateVMPoolProfiles(); e != nil {
		return e
	}
	if e := p.validateVnetProfile(); e != nil {
		return e
	}
	if e := p.validateDiagnosticsProfile(); e != nil {
		return e
	}
	return nil
}

func handleValidationErrors(e validator.ValidationErrors) error {
	// Override any version specific validation error message
	// common.HandleValidationErrors if the validation error message is general
	return common.HandleValidationErrors(e)
}

func (p *Properties) validateVMPoolProfiles() error {
	var hasLinux, hasWindows bool
	names := map[string]bool{}
	for _, vm := range p.VMProfiles {
		if names[vm.Name] {
			return fmt.Errorf("Duplicated VM pool name %s", vm.Name)
		}
		names[vm.Name] = true

		if len(vm.OSType) == 0 {
			return fmt.Errorf("OS type is not specified")
		}
		switch vm.OSType {
		case Linux:
			hasLinux = true
		case Windows:
			hasWindows = true
		default:
			return fmt.Errorf("OS type '%s' is not supported", vm.OSType)
		}
		if len(vm.OSDiskType) > 0 {
			found := false
			for _, t := range AllowedOsDiskTypes {
				if t == vm.OSDiskType {
					found = true
					break
				}
			}
			if !found {
				return fmt.Errorf("OS disk type '%s' is not included in supported [%s]", vm.OSDiskType, strings.Join(AllowedOsDiskTypes, ","))
			}
		}
		if len(vm.Ports) > 0 {
			if e := validateUniquePorts(vm.Ports, vm.Name); e != nil {
				return e
			}
		}
	}
	if hasLinux {
		if e := validateLinuxProfile(p.LinuxProfile); e != nil {
			return e
		}
	}
	if hasWindows {
		if e := validateWindowsProfile(p.WindowsProfile); e != nil {
			return e
		}
	}
	return nil
}

func validateLinuxProfile(p *LinuxProfile) error {
	if p == nil {
		return fmt.Errorf("LinuxProfile cannot be empty")
	}
	if len(p.AdminUsername) == 0 {
		return fmt.Errorf("LinuxProfile.AdminUsername cannot be empty")
	}
	if len(p.AdminPassword) > 0 && len(p.SSHPubKeys) > 0 {
		return fmt.Errorf("AdminPassword and SSH public keys are mutually exclusive")
	}
	if len(p.AdminPassword) == 0 && len(p.SSHPubKeys) == 0 {
		return fmt.Errorf("Must specify either AdminPassword or SSH public keys")
	}
	for i, key := range p.SSHPubKeys {
		if key == nil || len(key.KeyData) == 0 {
			return fmt.Errorf("SSH public key #%d cannot be empty", i)
		}
	}
	if p.OSImage != nil {
		if err := validateOSImage(p.OSImage); err != nil {
			return err
		}
	}
	return nil
}

func validateWindowsProfile(p *WindowsProfile) error {
	if p == nil {
		return fmt.Errorf("WindowsProfile cannot be empty")
	}
	if e := validate.Var(p.AdminUsername, "required"); e != nil {
		return fmt.Errorf("WindowsProfile.AdminUsername cannot be empty")
	}
	if e := validate.Var(p.AdminPassword, "required"); e != nil {
		return fmt.Errorf("WindowsProfile.AdminPassword cannot be empty")
	}
	if p.OSImage != nil {
		if err := validateOSImage(p.OSImage); err != nil {
			return err
		}
	}
	return nil
}

func validateOSImage(p *OSImage) error {
	if p == nil {
		return nil
	}
	if len(p.URL) > 0 && (len(p.Publisher) > 0 || len(p.Offer) > 0 || len(p.SKU) > 0 || len(p.Version) > 0) {
		return fmt.Errorf("OSImage URL and Publisher/Offer/SKU are mutually exclusive")
	}
	if len(p.Publisher) > 0 || len(p.Offer) > 0 || len(p.SKU) > 0 || len(p.Version) > 0 {
		if len(p.Publisher) == 0 {
			return fmt.Errorf("OSImage Publisher is not set")
		}
		if len(p.Offer) == 0 {
			return fmt.Errorf("OSImage Offer is not set")
		}
		if len(p.SKU) == 0 {
			return fmt.Errorf("OSImage SKU is not set")
		}
		// version is optional
	}
	return nil
}

func (p *Properties) validateDiagnosticsProfile() error {
	if p.DiagnosticsProfile == nil || !p.DiagnosticsProfile.Enabled {
		return nil
	}
	if len(p.DiagnosticsProfile.StorageAccountName) == 0 {
		return fmt.Errorf("DiagnosticsProfile.StorageAccountName cannot be empty string")
	}
	return nil
}

func (p *Properties) validateVnetProfile() error {
	h := p.VnetProfile
	if h == nil {
		return nil
	}
	// existing vnet is uniquely defined by resource group, vnet name, and subnet name
	if len(h.VnetResourceGroup) > 0 {
		if len(h.VnetName) == 0 {
			return fmt.Errorf("vnetProfile.vnetName cannot be empty for existing vnet")
		}
		if len(h.SubnetName) == 0 {
			return fmt.Errorf("vnetProfile.subnetName cannot be empty for existing vnet")
		}
		if len(h.VnetAddress) > 0 {
			return fmt.Errorf("vnetProfile.VnetResourceGroup and vnetProfile.vnetAddress are mutually exclusive")
		}
		if len(h.SubnetAddress) > 0 {
			return fmt.Errorf("vnetProfile.VnetResourceGroup and vnetProfile.subnetAddress are mutually exclusive")
		}
	}
	return nil
}

func validateUniquePorts(ports []int, name string) error {
	portMap := make(map[int]bool)
	for _, port := range ports {
		if _, ok := portMap[port]; ok {
			return fmt.Errorf("VM '%s' has duplicate port '%d', ports must be unique", name, port)
		}
		portMap[port] = true
	}
	return nil
}
