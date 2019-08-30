package engine

import (
	"fmt"
	"strconv"

	"github.com/Microsoft/oe-engine/pkg/api"
)

func getParameters(cs *api.OpenEnclave, generatorCode string) (paramsMap, error) {
	properties := cs.Properties
	location := cs.Location
	parametersMap := paramsMap{}

	if len(cs.Location) > 0 {
		addValue(parametersMap, "location", location)
	}

	for _, vm := range properties.VMProfiles {
		addValue(parametersMap, fmt.Sprintf("%sVMSize", vm.Name), vm.VMSize)
		addValue(parametersMap, fmt.Sprintf("%sOSType", vm.Name), vm.OSType)
		addValue(parametersMap, fmt.Sprintf("%sIsVanilla", vm.Name), strconv.FormatBool(vm.IsVanilla))
		addValue(parametersMap, fmt.Sprintf("%sEnableWinRM", vm.Name), strconv.FormatBool(vm.EnableWinRM))
		addValue(parametersMap, fmt.Sprintf("%sHasDNSName", vm.Name), strconv.FormatBool(vm.HasDNSName))
		if len(vm.OSDiskType) > 0 {
			addValue(parametersMap, fmt.Sprintf("%sOSDiskType", vm.Name), vm.OSDiskType)
		}
	}

	if properties.VnetProfile.IsCustomVNET() {
		addValue(parametersMap, "vnetNewOrExisting", "existing")
		addValue(parametersMap, "vnetResourceGroupName", properties.VnetProfile.VnetResourceGroup)
		addValue(parametersMap, "vnetName", properties.VnetProfile.VnetName)
		addValue(parametersMap, "subnetName", properties.VnetProfile.SubnetName)
	} else {
		addValue(parametersMap, "vnetNewOrExisting", "new")
		addValue(parametersMap, "subnetAddress", properties.VnetProfile.SubnetAddress)
	}

	if properties.LinuxProfile != nil {
		addValue(parametersMap, "linuxAdminUsername", properties.LinuxProfile.AdminUsername)
		if len(properties.LinuxProfile.AdminPassword) > 0 {
			addValue(parametersMap, "authenticationType", "password")
			addValue(parametersMap, "linuxAdminPassword", properties.LinuxProfile.AdminPassword)
		} else {
			addValue(parametersMap, "authenticationType", "sshPublicKey")
		}
		if properties.LinuxProfile.HasCustomImage() {
			addValue(parametersMap, "linuxImageSourceUrl", properties.LinuxProfile.OSImage.URL)
		} else {
			addValue(parametersMap, "linuxImagePublisher", properties.LinuxProfile.OSImage.Publisher)
			addValue(parametersMap, "linuxImageOffer", properties.LinuxProfile.OSImage.Offer)
			addValue(parametersMap, "linuxImageSKU", properties.LinuxProfile.OSImage.SKU)
			if len(properties.LinuxProfile.OSImage.Version) > 0 {
				addValue(parametersMap, "linuxImageVersion", properties.LinuxProfile.OSImage.Version)
			}
		}
	}
	if properties.WindowsProfile != nil {
		addValue(parametersMap, "windowsAdminUsername", properties.WindowsProfile.AdminUsername)
		addValue(parametersMap, "windowsAdminPassword", properties.WindowsProfile.AdminPassword)
		if properties.WindowsProfile.HasCustomImage() {
			addValue(parametersMap, "windowsImageSourceUrl", properties.WindowsProfile.OSImage.URL)
		} else {
			addValue(parametersMap, "windowsImagePublisher", properties.WindowsProfile.OSImage.Publisher)
			addValue(parametersMap, "windowsImageOffer", properties.WindowsProfile.OSImage.Offer)
			addValue(parametersMap, "windowsImageSKU", properties.WindowsProfile.OSImage.SKU)
			if len(properties.WindowsProfile.OSImage.Version) > 0 {
				addValue(parametersMap, "windowsImageVersion", properties.WindowsProfile.OSImage.Version)
			}
		}
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
