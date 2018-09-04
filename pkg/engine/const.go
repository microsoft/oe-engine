package engine

const (
	// DefaultGeneratorCode specifies the source generator of the cluster template.
	DefaultGeneratorCode = "oe-engine"
	// DefaultFirstConsecutiveStaticIP specifies the static IP address on VM # 0
	DefaultFirstConsecutiveStaticIP = "192.168.255.5"
	// DefaultMasterSubnet specifies the default subnet
	DefaultMasterSubnet = "192.168.255.0/24"
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
