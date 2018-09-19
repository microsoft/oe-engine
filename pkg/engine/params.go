package engine

import (
	"strconv"

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
		addValue(parametersMap, "vnetSubnetID", properties.MasterProfile.VnetSubnetID)
	} else {
		addValue(parametersMap, "subnet", properties.MasterProfile.Subnet)
	}
	addValue(parametersMap, "staticIP", properties.MasterProfile.StaticIP)
	addValue(parametersMap, "vmName", properties.MasterProfile.VMName)
	addValue(parametersMap, "vmSize", properties.MasterProfile.VMSize)
	addValue(parametersMap, "osImageName", properties.MasterProfile.OSImageName)
	if properties.MasterProfile.OSDiskSizeGB > 0 {
		addValue(parametersMap, "diskSizeGB", strconv.Itoa(properties.MasterProfile.OSDiskSizeGB))
	}
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
