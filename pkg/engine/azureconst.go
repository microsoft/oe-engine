package engine

import (
	"fmt"
	"strings"

	"github.com/Microsoft/oe-engine/pkg/api"
)

// AzureLocations provides all azure regions in prod.
// Related powershell to refresh this list:
//   Get-AzureRmLocation | Select-Object -Property Location
var AzureLocations = []string{
	"eastus",
}

// GetAllowedVMSizes returns allowed sizes for VM
func GetAllowedVMSizes() string {
	return `      "allowedValues": [
        "Standard_DC2s",
        "Standard_DC4s",
        "Standard_B1s"
        ],
        `
}

// GetOSImageNames returns allowed sizes and default OS image name
func GetOSImageNames() string {
	osNames := []string{}
	for k := range api.OsImageMap {
		osNames = append(osNames, fmt.Sprintf(`"%s"`, k))
	}
	strFormat := `      "allowedValues": [
    %s
    ],
    "defaultValue": "%s",
  `
	return fmt.Sprintf(strFormat, strings.Join(osNames, ",\n    "), api.OsImageDefault)
}

// GetOSImageReferences returns image references
func GetOSImageReferences() string {
	osRefs := []string{}
	osRefFormat := `"%s": {
            "publisher": "%s",
            "offer": "%s",
            "sku": "%s",
            "version": "%s"
          }`
	for osname, img := range api.OsImageMap {
		osRefs = append(osRefs, fmt.Sprintf(osRefFormat, osname, img.Publisher, img.Offer, img.SKU, img.Version))
	}

	strFormat := `"imageReference": {
    %s
  },
  `
	return fmt.Sprintf(strFormat, strings.Join(osRefs, ",\n    "))
}

// GetVMPlan returns VM plan
func GetVMPlan(osImageName string) string {
	img, ok := api.OsImageMap[osImageName]
	if !ok {
		return ""
	}
	strFormat := `"plan": {
  "name": "%s",
  "publisher": "%s",
  "product": "%s"
},`
	return fmt.Sprintf(strFormat, img.SKU, img.Publisher, img.Offer)
}
