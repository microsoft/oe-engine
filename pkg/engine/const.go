package engine

const (
	// DefaultGeneratorCode specifies the source generator of the cluster template.
	DefaultGeneratorCode = "oe-engine"
	// DefaultStaticIP specifies default static IP address
	DefaultStaticIP = "192.168.255.5"
	// DefaultSubnet specifies default subnet
	DefaultSubnet = "192.168.255.0/24"
	// DefaultPackageBaseURL specifies default package base URL
	DefaultPackageBaseURL = "https://oedownload.blob.core.windows.net/binaries"
)

const (
	baseFile      = "accbase.t"
	vars          = "vars.t"
	params        = "params.t"
	resources     = "resources.t"
	outputs       = "outputs.t"
	windowsParams = "windowsparams.t"
	customdata    = "customdata.t"

	provisionScript = "provision.sh"
	provisionSource = "provisionsource.sh"
)
