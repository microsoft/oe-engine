package api

import (
	neturl "net/url"
	"strings"
)

// OpenEnclave complies with the ARM model of
// resource definition in a JSON template.
type OpenEnclave struct {
	Location   string      `json:"location"`
	Properties *Properties `json:"properties,omitempty"`
}

// Properties represents the ACS cluster definition
type Properties struct {
	AgentPoolProfiles  []*AgentPoolProfile `json:"agentPoolProfiles,omitempty"`
	LinuxProfile       *LinuxProfile       `json:"linuxProfile,omitempty"`
	WindowsProfile     *WindowsProfile     `json:"windowsProfile,omitempty"`
	DiagnosticsProfile *DiagnosticsProfile `json:"diagnosticsProfile,omitempty"`
}

// LinuxProfile represents the linux parameters passed to the cluster
type LinuxProfile struct {
	AdminUsername string `json:"adminUsername"`
	SSH           struct {
		PublicKeys []PublicKey `json:"publicKeys"`
	} `json:"ssh"`
	Secrets            []KeyVaultSecrets   `json:"secrets,omitempty"`
	Distro             Distro              `json:"distro,omitempty"`
	ScriptRootURL      string              `json:"scriptroot,omitempty"`
	CustomSearchDomain *CustomSearchDomain `json:"customSearchDomain,omitempty"`
	CustomNodesDNS     *CustomNodesDNS     `json:"CustomNodesDNS,omitempty"`
}

// PublicKey represents an SSH key for LinuxProfile
type PublicKey struct {
	KeyData string `json:"keyData"`
}

// CustomSearchDomain represents the Search Domain when the custom vnet has a windows server DNS as a nameserver.
type CustomSearchDomain struct {
	Name          string `json:"name,omitempty"`
	RealmUser     string `json:"realmUser,omitempty"`
	RealmPassword string `json:"realmPassword,omitempty"`
}

// CustomNodesDNS represents the Search Domain when the custom vnet for a custom DNS as a nameserver.
type CustomNodesDNS struct {
	DNSServer string `json:"dnsServer,omitempty"`
}

// WindowsProfile represents the windows parameters passed to the cluster
type WindowsProfile struct {
	AdminUsername         string            `json:"adminUsername"`
	AdminPassword         string            `json:"adminPassword"`
	ImageVersion          string            `json:"imageVersion"`
	WindowsImageSourceURL string            `json:"windowsImageSourceURL"`
	WindowsPublisher      string            `json:"windowsPublisher"`
	WindowsOffer          string            `json:"windowsOffer"`
	WindowsSku            string            `json:"windowsSku"`
	Secrets               []KeyVaultSecrets `json:"secrets,omitempty"`
}

// ImageReference represents a reference to an Image resource in Azure.
type ImageReference struct {
	Name          string `json:"name,omitempty"`
	ResourceGroup string `json:"resourceGroup,omitempty"`
}

// AgentPoolProfile represents an agent pool definition
type AgentPoolProfile struct {
	Name                         string `json:"name"`
	Count                        int    `json:"count"`
	VMSize                       string `json:"vmSize"`
	OSDiskSizeGB                 int    `json:"osDiskSizeGB,omitempty"`
	DNSPrefix                    string `json:"dnsPrefix,omitempty"`
	OSType                       OSType `json:"osType,omitempty"`
	Ports                        []int  `json:"ports,omitempty"`
	AvailabilityProfile          string `json:"availabilityProfile"`
	ScaleSetPriority             string `json:"scaleSetPriority,omitempty"`
	ScaleSetEvictionPolicy       string `json:"scaleSetEvictionPolicy,omitempty"`
	StorageProfile               string `json:"storageProfile,omitempty"`
	DiskSizesGB                  []int  `json:"diskSizesGB,omitempty"`
	VnetSubnetID                 string `json:"vnetSubnetID,omitempty"`
	Subnet                       string `json:"subnet"`
	IPAddressCount               int    `json:"ipAddressCount,omitempty"`
	Distro                       Distro `json:"distro,omitempty"`
	AcceleratedNetworkingEnabled bool   `json:"acceleratedNetworkingEnabled,omitempty"`

	FQDN             string            `json:"fqdn,omitempty"`
	CustomNodeLabels map[string]string `json:"customNodeLabels,omitempty"`
	ImageRef         *ImageReference   `json:"imageReference,omitempty"`
}

// DiagnosticsProfile setting to enable/disable capturing
// diagnostics for VMs hosting container cluster.
type DiagnosticsProfile struct {
	VMDiagnostics *VMDiagnostics `json:"vmDiagnostics"`
}

// VMDiagnostics contains settings to on/off boot diagnostics collection
// in RD Host
type VMDiagnostics struct {
	Enabled bool `json:"enabled"`

	// Specifies storage account Uri where Boot Diagnostics (CRP &
	// VMSS BootDiagostics) and VM Diagnostics logs (using Linux
	// Diagnostics Extension) will be stored. Uri will be of standard
	// blob domain. i.e. https://storageaccount.blob.core.windows.net/
	// This field is readonly as ACS RP will create a storage account
	// for the customer.
	StorageURL *neturl.URL `json:"storageUrl"`
}

// KeyVaultSecrets specifies certificates to install on the pool
// of machines from a given key vault
// the key vault specified must have been granted read permissions to CRP
type KeyVaultSecrets struct {
	SourceVault       *KeyVaultID           `json:"sourceVault,omitempty"`
	VaultCertificates []KeyVaultCertificate `json:"vaultCertificates,omitempty"`
}

// KeyVaultID specifies a key vault
type KeyVaultID struct {
	ID string `json:"id,omitempty"`
}

// KeyVaultCertificate specifies a certificate to install
// On Linux, the certificate file is placed under the /var/lib/waagent directory
// with the file name <UppercaseThumbprint>.crt for the X509 certificate file
// and <UppercaseThumbprint>.prv for the private key. Both of these files are .pem formatted.
// On windows the certificate will be saved in the specified store.
type KeyVaultCertificate struct {
	CertificateURL   string `json:"certificateUrl,omitempty"`
	CertificateStore string `json:"certificateStore,omitempty"`
}

// OSType represents OS types of agents
type OSType string

// Distro represents Linux distro to use for Linux VMs
type Distro string

// HasWindows returns true if the cluster contains windows
func (p *Properties) HasWindows() bool {
	for _, agentPoolProfile := range p.AgentPoolProfiles {
		if agentPoolProfile.OSType == Windows {
			return true
		}
	}
	return false
}

// HasManagedDisks returns true if the cluster contains Managed Disks
func (p *Properties) HasManagedDisks() bool {
	for _, agentPoolProfile := range p.AgentPoolProfiles {
		if agentPoolProfile.StorageProfile == ManagedDisks {
			return true
		}
	}
	return false
}

// HasStorageAccountDisks returns true if the cluster contains Storage Account Disks
func (p *Properties) HasStorageAccountDisks() bool {
	for _, agentPoolProfile := range p.AgentPoolProfiles {
		if agentPoolProfile.StorageProfile == StorageAccount {
			return true
		}
	}
	return false
}

// TotalNodes returns the total number of nodes in the cluster configuration
func (p *Properties) TotalNodes() int {
	var totalNodes int
	for _, pool := range p.AgentPoolProfiles {
		totalNodes = totalNodes + pool.Count
	}
	return totalNodes
}

// HasVirtualMachineScaleSets returns true if the cluster contains Virtual Machine Scale Sets
func (p *Properties) HasVirtualMachineScaleSets() bool {
	for _, agentPoolProfile := range p.AgentPoolProfiles {
		if agentPoolProfile.AvailabilityProfile == VirtualMachineScaleSets {
			return true
		}
	}
	return false
}

// IsCustomVNET returns true if the customer brought their own VNET
func (h *AgentPoolProfile) IsCustomVNET() bool {
	return len(h.VnetSubnetID) > 0
}

// IsWindows returns true if the agent pool is windows
func (h *AgentPoolProfile) IsWindows() bool {
	return h.OSType == Windows
}

// IsLinux returns true if the agent pool is linux
func (h *AgentPoolProfile) IsLinux() bool {
	return h.OSType == Linux
}

// IsAvailabilitySets returns true if the customer specified disks
func (h *AgentPoolProfile) IsAvailabilitySets() bool {
	return h.AvailabilityProfile == AvailabilitySet
}

// IsVirtualMachineScaleSets returns true if the agent pool availability profile is VMSS
func (h *AgentPoolProfile) IsVirtualMachineScaleSets() bool {
	return h.AvailabilityProfile == VirtualMachineScaleSets
}

// IsLowPriorityScaleSet returns true if the VMSS is Low Priority
func (h *AgentPoolProfile) IsLowPriorityScaleSet() bool {
	return h.AvailabilityProfile == VirtualMachineScaleSets && h.ScaleSetPriority == ScaleSetPriorityLow
}

// IsManagedDisks returns true if the customer specified disks
func (h *AgentPoolProfile) IsManagedDisks() bool {
	return h.StorageProfile == ManagedDisks
}

// IsStorageAccount returns true if the customer specified storage account
func (h *AgentPoolProfile) IsStorageAccount() bool {
	return h.StorageProfile == StorageAccount
}

// HasDisks returns true if the customer specified disks
func (h *AgentPoolProfile) HasDisks() bool {
	return len(h.DiskSizesGB) > 0
}

// IsAcceleratedNetworkingEnabled returns true if the customer enabled Accelerated Networking
func (h *AgentPoolProfile) IsAcceleratedNetworkingEnabled() bool {
	return h.AcceleratedNetworkingEnabled
}

// HasSecrets returns true if the customer specified secrets to install
func (w *WindowsProfile) HasSecrets() bool {
	return len(w.Secrets) > 0
}

// HasCustomImage returns true if there is a custom windows os image url specified
func (w *WindowsProfile) HasCustomImage() bool {
	return len(w.WindowsImageSourceURL) > 0
}

// HasSecrets returns true if the customer specified secrets to install
func (l *LinuxProfile) HasSecrets() bool {
	return len(l.Secrets) > 0
}

// HasSearchDomain returns true if the customer specified secrets to install
func (l *LinuxProfile) HasSearchDomain() bool {
	if l.CustomSearchDomain != nil {
		if l.CustomSearchDomain.Name != "" && l.CustomSearchDomain.RealmPassword != "" && l.CustomSearchDomain.RealmUser != "" {
			return true
		}
	}
	return false
}

// HasCustomNodesDNS returns true if the customer specified a dns server
func (l *LinuxProfile) HasCustomNodesDNS() bool {
	if l.CustomNodesDNS != nil {
		if l.CustomNodesDNS.DNSServer != "" {
			return true
		}
	}
	return false
}

func isNSeriesSKU(p *Properties) bool {
	for _, profile := range p.AgentPoolProfiles {
		if strings.Contains(profile.VMSize, "Standard_N") {
			return true
		}
	}
	return false
}
