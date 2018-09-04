package engine

import (
	"bytes"
	"fmt"
	"sort"
	"strings"

	"github.com/Microsoft/oe-engine/pkg/api"
)

var (

	//DefaultUbuntuImageConfig is the default Linux distribution.
	DefaultUbuntuImageConfig = AzureOSImageConfig{
		ImageOffer:     "UbuntuServer",
		ImageSku:       "18.04-LTS",
		ImagePublisher: "Canonical",
		ImageVersion:   "latest",
	}
)

// setPropertiesDefaults for the container Properties, returns true if certs are generated
func setPropertiesDefaults(oe *api.OpenEnclave, isUpgrade bool) {
	setMasterNetworkDefaults(oe.Properties, isUpgrade)
	setStorageDefaults(oe.Properties)
}

// SetMasterNetworkDefaults for masters
func setMasterNetworkDefaults(a *api.Properties, isUpgrade bool) {
	if a.MasterProfile == nil {
		return
	}

	if !a.MasterProfile.IsCustomVNET() {
		a.MasterProfile.Subnet = DefaultMasterSubnet
		// FirstConsecutiveStaticIP is not reset if it is upgrade and some value already exists
		if !isUpgrade || len(a.MasterProfile.FirstConsecutiveStaticIP) == 0 {
			a.MasterProfile.FirstConsecutiveStaticIP = DefaultFirstConsecutiveStaticIP
		}
	}

	// Set the default number of IP addresses allocated for masters.
	if a.MasterProfile.IPAddressCount == 0 {
		// Allocate one IP address for the node.
		a.MasterProfile.IPAddressCount = 1
	}

	if a.MasterProfile.HTTPSourceAddressPrefix == "" {
		a.MasterProfile.HTTPSourceAddressPrefix = "*"
	}
}

// setStorageDefaults for agents
func setStorageDefaults(a *api.Properties) {
	if a.MasterProfile != nil && len(a.MasterProfile.StorageProfile) == 0 {
		a.MasterProfile.StorageProfile = api.ManagedDisks
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
