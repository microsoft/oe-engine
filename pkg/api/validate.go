package api

import (
	"strings"
	"fmt"
	"net"
	"net/url"
	"regexp"

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
	if a.LinuxProfile != nil && a.WindowsProfile != nil {
		return fmt.Errorf("Linux and Windows profiles are mutually exclusive")
	}
	if e := a.validateMasterProfile(); e != nil {
		return e
	}
	if e := a.validateLinuxProfile(); e != nil {
		return e
	}
	if e := a.validateWindowsProfile(); e != nil {
		return e
	}
	if e := a.validateVNET(); e != nil {
		return e
	}
	return nil
}

func handleValidationErrors(e validator.ValidationErrors) error {
	// Override any version specific validation error message
	// common.HandleValidationErrors if the validation error message is general
	return common.HandleValidationErrors(e)
}

func (a *Properties) validateMasterProfile() error {
	m := a.MasterProfile
	if m == nil {
		return nil
	}
	if len(m.StaticIP) > 0 {
		if net.ParseIP(m.StaticIP) == nil {
			return fmt.Errorf("StaticIP '%s' is an invalid IP address", m.StaticIP)
		}
	}
	if len(m.OSImageName) > 0 {
		if _, ok := OsImageMap[m.OSImageName]; !ok {
			return fmt.Errorf("OS image '%s' is not supported", m.OSImageName)
		}
	}
	if len(m.StorageType) > 0 {
		found := false
		for _, t := range AllowedStorageAccountTypes {
			if t == m.StorageType {
				found = true
				break
			}
		}
		if !found {
			return fmt.Errorf("Storage account type '%s' is not included in supported [%s]", m.StorageType, strings.Join(AllowedStorageAccountTypes, ","))
		}
	}
	if len(m.DNSPrefix) > 0 {
		if err := validateDNSName(m.DNSPrefix); err != nil {
			return err
		}
	}
	return nil
}

func (a *Properties) validateLinuxProfile() error {
	if a.LinuxProfile == nil {
		return nil
	}
	if e := validate.Var(a.LinuxProfile.SSH.PublicKeys[0].KeyData, "required"); e != nil {
		return fmt.Errorf("KeyData in LinuxProfile.SSH.PublicKeys cannot be empty string")
	}
	return validateKeyVaultSecrets(a.LinuxProfile.Secrets, false)
}

func (a *Properties) validateWindowsProfile() error {
	if a.WindowsProfile == nil {
		return nil
	}
	if e := validate.Var(a.WindowsProfile.AdminPassword, "required"); e != nil {
		return fmt.Errorf("WindowsProfile.AdminPassword cannot be empty string")
	}
	return nil
}

func (a *Properties) validateVNET() error {
	isCustomVNET := a.MasterProfile.IsCustomVNET()

	if isCustomVNET {
		_, _, _, _, e := common.GetVNETSubnetIDComponents(a.MasterProfile.VnetSubnetID)
		if e != nil {
			return e
		}

		statisIP := net.ParseIP(a.MasterProfile.StaticIP)
		if statisIP == nil {
			return fmt.Errorf("MasterProfile.StaticIP (with VNET Subnet specification) '%s' is an invalid IP address", a.MasterProfile.StaticIP)
		}

		if a.MasterProfile.VnetCidr != "" {
			_, _, err := net.ParseCIDR(a.MasterProfile.VnetCidr)
			if err != nil {
				return fmt.Errorf("MasterProfile.VnetCidr '%s' contains invalid cidr notation", a.MasterProfile.VnetCidr)
			}
		}
	}
	return nil
}

func validateKeyVaultSecrets(secrets []KeyVaultSecrets, requireCertificateStore bool) error {
	for _, s := range secrets {
		if len(s.VaultCertificates) == 0 {
			return fmt.Errorf("Invalid KeyVaultSecrets must have no empty VaultCertificates")
		}
		if s.SourceVault == nil {
			return fmt.Errorf("missing SourceVault in KeyVaultSecrets")
		}
		if s.SourceVault.ID == "" {
			return fmt.Errorf("KeyVaultSecrets must have a SourceVault.ID")
		}
		for _, c := range s.VaultCertificates {
			if _, e := url.Parse(c.CertificateURL); e != nil {
				return fmt.Errorf("Certificate url was invalid. received error %s", e)
			}
			if e := validateName(c.CertificateStore, "KeyVaultCertificate.CertificateStore"); requireCertificateStore && e != nil {
				return fmt.Errorf("%s for certificates in a WindowsProfile", e)
			}
		}
	}
	return nil
}

// Validate ensures that the WindowsProfile is valid
func (w *WindowsProfile) Validate(orchestratorType string) error {
	if e := validate.Var(w.AdminUsername, "required"); e != nil {
		return fmt.Errorf("WindowsProfile.AdminUsername is required, when agent pool specifies windows")
	}
	if e := validate.Var(w.AdminPassword, "required"); e != nil {
		return fmt.Errorf("WindowsProfile.AdminPassword is required, when agent pool specifies windows")
	}
	return validateKeyVaultSecrets(w.Secrets, true)
}

func validateName(name string, label string) error {
	if name == "" {
		return fmt.Errorf("%s must be a non-empty value", label)
	}
	return nil
}

func validatePoolName(poolName string) error {
	// we will cap at length of 12 and all lowercase letters since this makes up the VMName
	poolNameRegex := `^([a-z][a-z0-9]{0,11})$`
	re, err := regexp.Compile(poolNameRegex)
	if err != nil {
		return err
	}
	submatches := re.FindStringSubmatch(poolName)
	if len(submatches) != 2 {
		return fmt.Errorf("pool name '%s' is invalid. A pool name must start with a lowercase letter, have max length of 12, and only have characters a-z0-9", poolName)
	}
	return nil
}

func validateDNSName(dnsName string) error {
	dnsNameRegex := `^([A-Za-z][A-Za-z0-9-]{1,43}[A-Za-z0-9])$`
	re, err := regexp.Compile(dnsNameRegex)
	if err != nil {
		return err
	}
	if !re.MatchString(dnsName) {
		return fmt.Errorf("DNS name '%s' is invalid. The DNS name must contain between 3 and 45 characters.  The name can contain only letters, numbers, and hyphens.  The name must start with a letter and must end with a letter or a number (length was %d)", dnsName, len(dnsName))
	}
	return nil
}

func validateUniquePorts(ports []int, name string) error {
	portMap := make(map[int]bool)
	for _, port := range ports {
		if _, ok := portMap[port]; ok {
			return fmt.Errorf("agent profile '%s' has duplicate port '%d', ports must be unique", name, port)
		}
		portMap[port] = true
	}
	return nil
}
