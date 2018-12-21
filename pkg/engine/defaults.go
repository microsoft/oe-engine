package engine

import (
	"bytes"
	"fmt"
	"sort"
	"strings"

	"github.com/Microsoft/oe-engine/pkg/api"
	log "github.com/sirupsen/logrus"
)

// setPropertiesDefaults for the container Properties, returns true if certs are generated
func setPropertiesDefaults(oe *api.OpenEnclave, isUpgrade bool) {
	for i, p := range oe.Properties.VMProfiles {
		if len(p.Name) == 0 {
			log.Warnf("Missing Name for VM pool #%d. Assuming %s", i, api.DefaultVMName)
			oe.Properties.VMProfiles[i].Name = api.DefaultVMName
		}
		if len(p.OSType) == 0 {
			log.Warnf("Missing OSType for VM pool #%d. Assuming %s", i, api.Linux)
			oe.Properties.VMProfiles[i].OSType = api.Linux
		}
	}
	// set network defaults
	if oe.Properties.VnetProfile == nil {
		oe.Properties.VnetProfile = &api.VnetProfile{}
	}
	if !oe.Properties.VnetProfile.IsCustomVNET() {
		if len(oe.Properties.VnetProfile.VnetAddress) == 0 {
			oe.Properties.VnetProfile.VnetAddress = api.DefaultVnet
		}
		if len(oe.Properties.VnetProfile.SubnetAddress) == 0 {
			oe.Properties.VnetProfile.SubnetAddress = api.DefaultSubnet
		}
	}
	// set default Linux OS image
	if oe.Properties.LinuxProfile != nil && !oe.Properties.LinuxProfile.HasCustomImage() {
		if oe.Properties.LinuxProfile.OSImage == nil {
			oe.Properties.LinuxProfile.OSImage = &api.DefaultLinuxImage
		}
	}
	// set default Windows OS image
	if oe.Properties.WindowsProfile != nil && !oe.Properties.WindowsProfile.HasCustomImage() {
		if oe.Properties.WindowsProfile.OSImage == nil {
			oe.Properties.WindowsProfile.OSImage = &api.DefaultWindowsImage
		}
	}
}

func combineValues(inputs ...string) string {
	valueMap := make(map[string]string)
	for _, input := range inputs {
		applyValueStringToMap(valueMap, input)
	}
	return mapToString(valueMap)
}

func applyValueStringToMap(valueMap map[string]string, input string) {
	values := strings.Split(input, ",")
	for index := 0; index < len(values); index++ {
		// trim spaces (e.g. if the input was "foo=true, bar=true" - we want to drop the space after the comma)
		value := strings.Trim(values[index], " ")
		valueParts := strings.Split(value, "=")
		if len(valueParts) == 2 {
			valueMap[valueParts[0]] = valueParts[1]
		}
	}
}

func mapToString(valueMap map[string]string) string {
	// Order by key for consistency
	keys := []string{}
	for key := range valueMap {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	var buf bytes.Buffer
	for _, key := range keys {
		buf.WriteString(fmt.Sprintf("%s=%s,", key, valueMap[key]))
	}
	return strings.TrimSuffix(buf.String(), ",")
}
