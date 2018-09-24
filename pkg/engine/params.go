package engine

import (
	"github.com/Microsoft/oe-engine/pkg/api"
)

func getParameters(cs *api.OpenEnclave, generatorCode string) (paramsMap, error) {
	properties := cs.Properties
	location := cs.Location
	parametersMap := paramsMap{}

	if len(cs.Location) > 0 {
		addValue(parametersMap, "location", location)
	}
	addValue(parametersMap, "vmName", properties.MasterProfile.VMName)
	addValue(parametersMap, "vmSize", properties.MasterProfile.VMSize)
	addValue(parametersMap, "osImageName", properties.MasterProfile.OSImageName)
	addValue(parametersMap, "publicInboundPorts", "enable")

	if len(properties.MasterProfile.OSDiskType) > 0 {
		addValue(parametersMap, "osDiskType", properties.MasterProfile.OSDiskType)
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
		addValue(parametersMap, "authenticationType", "password")
		addValue(parametersMap, "adminUsername", properties.WindowsProfile.AdminUsername)
		addValue(parametersMap, "adminPasswordOrKey", properties.WindowsProfile.AdminPassword)
	}

	if properties.LinuxProfile != nil && !cs.OeSdkExcluded {
		addValue(parametersMap, "oeSDKIncluded", "yes")
	} else {
		addValue(parametersMap, "oeSDKIncluded", "no")
	}

	if properties.DiagnosticsProfile != nil && properties.DiagnosticsProfile.Enabled {
		addValue(parametersMap, "bootDiagnostics", "enable")
		addValue(parametersMap, "diagnosticsStorageAccountName", properties.DiagnosticsProfile.StorageAccountName)
		if properties.DiagnosticsProfile.IsNewStorageAccount {
			addValue(parametersMap, "diagnosticsStorageAccountNewOrExisting", "new")
		} else {
			addValue(parametersMap, "diagnosticsStorageAccountNewOrExisting", "existing")
		}
	} else {
		addValue(parametersMap, "bootDiagnostics", "disable")
	}

	return parametersMap, nil
}
