package engine

import (
	"github.com/Microsoft/oe-engine/pkg/api"
)

func getParameters(cs *api.OpenEnclave, generatorCode string) (paramsMap, error) {
	properties := cs.Properties
	location := cs.Location
	parametersMap := paramsMap{}

	// Common Parameters
	if len(cs.Location) > 0 {
		addValue(parametersMap, "location", location)
	}
	if len(properties.MasterProfile.StorageType) > 0 {
		addValue(parametersMap, "storageAccountType", properties.MasterProfile.StorageType)
	}

	if properties.MasterProfile.IsCustomVNET() {
		addValue(parametersMap, "vnetNewOrExisting", "existing")
		addValue(parametersMap, "vnetResourceGroupName", properties.MasterProfile.VnetResourceGroup)
		addValue(parametersMap, "vnetName", properties.MasterProfile.VnetName)
		addValue(parametersMap, "subnetName", properties.MasterProfile.SubnetName)
	} else {
		addValue(parametersMap, "vnetNewOrExisting", "new")
		addValue(parametersMap, "subnetAddress", properties.MasterProfile.SubnetAddress)
	}
	addValue(parametersMap, "vmName", properties.MasterProfile.VMName)
	addValue(parametersMap, "vmSize", properties.MasterProfile.VMSize)
	addValue(parametersMap, "osImageName", properties.MasterProfile.OSImageName)

	if properties.LinuxProfile != nil {
		addValue(parametersMap, "adminUsername", properties.LinuxProfile.AdminUsername)
		if len(properties.LinuxProfile.AdminPassword) > 0 {
			addValue(parametersMap, "authenticationType", "password")
			addValue(parametersMap, "adminPasswordOrKey", properties.LinuxProfile.AdminPassword)
		} else {
			addValue(parametersMap, "authenticationType", "sshPublicKey")
			addValue(parametersMap, "adminPasswordOrKey", properties.LinuxProfile.SSH.PublicKeys[0].KeyData)
		}
	}
	if properties.WindowsProfile != nil {
		addValue(parametersMap, "adminUsername", properties.WindowsProfile.AdminUsername)
		addValue(parametersMap, "authenticationType", "password")
		addValue(parametersMap, "adminPasswordOrKey", properties.WindowsProfile.AdminPassword)
	}

	return parametersMap, nil
}
