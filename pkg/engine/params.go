package engine

import (
	"github.com/Microsoft/oe-engine/pkg/api"
)

func getParameters(cs *api.OpenEnclave, generatorCode string) (paramsMap, error) {
	properties := cs.Properties
	location := cs.Location
	parametersMap := paramsMap{}

	// Common Parameters
	addValue(parametersMap, "location", location)

	//addValue(parametersMap, "fqdnEndpointSuffix", cloudSpecConfig.EndpointConfig.ResourceManagerVMDNSSuffix)
	addValue(parametersMap, "linuxAdminUsername", properties.LinuxProfile.AdminUsername)

	addValue(parametersMap, "masterEndpointDNSNamePrefix", properties.MasterProfile.DNSPrefix)

	if properties.MasterProfile != nil {
		if properties.MasterProfile.IsCustomVNET() {
			addValue(parametersMap, "masterVnetSubnetID", properties.MasterProfile.VnetSubnetID)
		} else {
			addValue(parametersMap, "masterSubnet", properties.MasterProfile.Subnet)
		}
		addValue(parametersMap, "firstConsecutiveStaticIP", properties.MasterProfile.FirstConsecutiveStaticIP)
		addValue(parametersMap, "masterVMSize", properties.MasterProfile.VMSize)
	}
	addValue(parametersMap, "sshRSAPublicKey", properties.LinuxProfile.SSH.PublicKeys[0].KeyData)

	return parametersMap, nil
}
