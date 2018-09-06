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

	addValue(parametersMap, "adminUsername", properties.LinuxProfile.AdminUsername)

	addValue(parametersMap, "dnsNamePrefix", properties.MasterProfile.DNSPrefix)

	if properties.MasterProfile.IsCustomVNET() {
		addValue(parametersMap, "vnetSubnetID", properties.MasterProfile.VnetSubnetID)
	} else {
		addValue(parametersMap, "subnet", properties.MasterProfile.Subnet)
	}
	addValue(parametersMap, "staticIP", properties.MasterProfile.StaticIP)
	addValue(parametersMap, "vmSize", properties.MasterProfile.VMSize)
	addValue(parametersMap, "osImageName", properties.MasterProfile.OSImageName)

	if properties.LinuxProfile != nil {
		addValue(parametersMap, "sshRSAPublicKey", properties.LinuxProfile.SSH.PublicKeys[0].KeyData)
	}

	return parametersMap, nil
}
