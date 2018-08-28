package engine

const (
	// DefaultAgentSubnetTemplate specifies a default agent subnet
	DefaultAgentSubnetTemplate = "10.%d.0.0/16"
	// DefaultGeneratorCode specifies the source generator of the cluster template.
	DefaultGeneratorCode = "oe-engine"
)

const (
	baseFile      = "accbase.t"
	vars          = "vars.t"
	agentVars     = "agentvars.t"
	params        = "params.t"
	resources     = "resources.t"
	outputs       = "outputs.t"
	windowsParams = "windowsparams.t"

	agentOutputs              = "agentoutputs.t"
	agentParams               = "agentparams.t"
	agentResourcesVMAS        = "agentresourcesvmas.t"
	agentResourcesVMSS        = "agentresourcesvmss.t"
	windowsAgentResourcesVMAS = "windowsAgentResourcesVmas.t"
	windowsAgentResourcesVMSS = "windowsAgentResourcesVmss.t"
)
