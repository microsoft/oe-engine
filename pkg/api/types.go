package api

// OpenEnclave complies with the ARM model of
// resource definition in a JSON template.
type OpenEnclave struct {
	Location       string      `json:"location"`
	OeSdkExcluded  bool        `json:"oeSdkExcluded"`
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
	AdminUsername      string              `json:"adminUsername"`
	AdminPassword      string              `json:"adminPassword"`
	SSHPubKey          string              `json:"sshPublicKey"`
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
	AdminUsername         string `json:"adminUsername"`
	AdminPassword         string `json:"adminPassword"`
	SSHPubKey             string `json:"sshPublicKey"`
	ImageVersion          string `json:"imageVersion"`
	WindowsImageSourceURL string `json:"windowsImageSourceURL"`
	WindowsPublisher      string `json:"windowsPublisher"`
	WindowsOffer          string `json:"windowsOffer"`
	WindowsSku            string `json:"windowsSku"`
}

// VMProfile represents the definition of a VM
type VMProfile struct {
	Name        string `json:"name"`
	OSImageName string `json:"osImageName"`
	OSDiskType  string `json:"osDiskType"`
	VMSize      string `json:"vmSize"`
	Ports       []int  `json:"ports,omitempty"`
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

// IsCustomVNET returns true if the customer brought their own VNET
func (p *VnetProfile) IsCustomVNET() bool {
	return len(p.VnetResourceGroup) > 0 && len(p.VnetName) > 0 && len(p.SubnetName) > 0
}

// HasCustomImage returns true if there is a custom windows os image url specified
func (w *WindowsProfile) HasCustomImage() bool {
	return len(w.WindowsImageSourceURL) > 0
}
