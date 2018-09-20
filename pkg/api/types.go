package api

import (
	neturl "net/url"
)

// OpenEnclave complies with the ARM model of
// resource definition in a JSON template.
type OpenEnclave struct {
	Location       string      `json:"location"`
	PackageBaseURL string      `json:"packageBaseURL"`
	Properties     *Properties `json:"properties,omitempty"`
}

// Properties represents the ACS cluster definition
type Properties struct {
	MasterProfile      *MasterProfile      `json:"masterProfile,omitempty"`
	LinuxProfile       *LinuxProfile       `json:"linuxProfile,omitempty"`
	WindowsProfile     *WindowsProfile     `json:"windowsProfile,omitempty"`
	DiagnosticsProfile *DiagnosticsProfile `json:"diagnosticsProfile,omitempty"`
}

// LinuxProfile represents the linux parameters passed to the cluster
type LinuxProfile struct {
	AdminUsername string `json:"adminUsername"`
	AdminPassword string `json:"adminPassword"`
	SSH           struct {
		PublicKeys []PublicKey `json:"publicKeys"`
	} `json:"ssh"`
	Secrets            []KeyVaultSecrets   `json:"secrets,omitempty"`
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

// MasterProfile represents the definition of the master cluster
type MasterProfile struct {
	VMName            string `json:"vmName"`
	OSImageName       string `json:"osImageName"`
	OSDiskType        string `json:"osDiskType"`
	VMSize            string `json:"vmSize"`
	VnetResourceGroup string `json:"vnetResourceGroup,omitempty"`
	VnetName          string `json:"vnetName,omitempty"`
	VnetAddress       string `json:"vnetAddress,omitempty"`
	SubnetName        string `json:"subnetName,omitempty"`
	SubnetAddress     string `json:"subnetAddress,omitempty"`
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

// IsWindows returns true for Windows VM
func (p *Properties) IsWindows() bool {
	return p.WindowsProfile != nil
}

// IsLinux returns true for Linux VM
func (p *Properties) IsLinux() bool {
	return p.LinuxProfile != nil
}

// IsCustomVNET returns true if the customer brought their own VNET
func (m *MasterProfile) IsCustomVNET() bool {
	return len(m.VnetResourceGroup) > 0 && len(m.VnetName) > 0 && len(m.SubnetName) > 0
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
