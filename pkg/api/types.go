package api

// OpenEnclave complies with the ARM model of
// resource definition in a JSON template.
type OpenEnclave struct {
	Location       string      `json:"location"`
	PackageBaseURL string      `json:"packageBaseURL"`
	Properties     *Properties `json:"properties,omitempty"`
}

// Properties represents the ACS cluster definition
type Properties struct {
	VnetProfile        *VnetProfile        `json:"vnetProfile"`
	VMProfiles         []*VMProfile        `json:"vmProfiles"`
	LinuxProfile       *LinuxProfile       `json:"linuxProfile,omitempty"`
	WindowsProfile     *WindowsProfile     `json:"windowsProfile,omitempty"`
	DiagnosticsProfile *DiagnosticsProfile `json:"diagnosticsProfile,omitempty"`
}

// LinuxProfile represents the linux parameters passed to the cluster
type LinuxProfile struct {
	AdminUsername string       `json:"adminUsername" validate:"required"`
	AdminPassword string       `json:"adminPassword"`
	SSHPubKeys    []*PublicKey `json:"sshPublicKeys"`
}

// WindowsProfile represents the windows parameters passed to the cluster
type WindowsProfile struct {
	AdminUsername         string `json:"adminUsername" validate:"required"`
	AdminPassword         string `json:"adminPassword" validate:"required"`
	SSHPubKey             string `json:"sshPublicKey,omitempty"`
	WindowsImageSourceURL string `json:"windowsImageSourceURL,omitempty"`
}

// VMProfile represents the definition of a VM
type VMProfile struct {
	Name        string `json:"name"`
	OSImageName string `json:"osImageName"`
	OSDiskType  string `json:"osDiskType"`
	VMSize      string `json:"vmSize"`
	Ports       []int  `json:"ports,omitempty"`
	IsVanilla   bool   `json:"isVanilla"`
	HasDNSName  bool   `json:"hasDNSName"`
}

// VnetProfile represents the definition of a vnet
type VnetProfile struct {
	VnetResourceGroup string `json:"vnetResourceGroup,omitempty"`
	VnetName          string `json:"vnetName,omitempty"`
	VnetAddress       string `json:"vnetAddress,omitempty"`
	SubnetName        string `json:"subnetName,omitempty"`
	SubnetAddress     string `json:"subnetAddress,omitempty"`
}

// DiagnosticsProfile contains settings to on/off boot diagnostics collection
// in RD Host
type DiagnosticsProfile struct {
	Enabled             bool   `json:"enabled"`
	StorageAccountName  string `json:"storageAccountName"`
	IsNewStorageAccount bool   `json:"isNewStorageAccount"`
}

// PublicKey contains puvlic SSH key
type PublicKey struct {
	KeyData string `json:"keyData"`
}

// IsCustomVNET returns true if the customer brought their own VNET
func (p *VnetProfile) IsCustomVNET() bool {
	return len(p.VnetResourceGroup) > 0 && len(p.VnetName) > 0 && len(p.SubnetName) > 0
}

// HasCustomImage returns true if there is a custom windows os image url specified
func (w *WindowsProfile) HasCustomImage() bool {
	return len(w.WindowsImageSourceURL) > 0
}
