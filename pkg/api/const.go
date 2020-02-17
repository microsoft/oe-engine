package api

import (
	"fmt"
	"strings"
)

const (
	// DefaultVMName is default VM pool name
	DefaultVMName = "accVM"
	// DefaultGeneratorCode specifies the source generator of the cluster template.
	DefaultGeneratorCode = "oe-engine"
	// DefaultVnet specifies default vnet address space
	DefaultVnet = "10.0.0.0/16"
	// DefaultSubnet specifies default subnet
	DefaultSubnet = "10.0.0.0/24"
	// DefaultOsDiskType specifies default OS disk type
	DefaultOsDiskType = "Premium_LRS"
)

const (
	// Windows OSType
	Windows OSType = "Windows"
	// Linux OSType
	Linux OSType = "Linux"
)

// DefaultLinuxImage specifies default Linux OS image
var DefaultLinuxImage = OSImage{
	Publisher: "Canonical",
	Offer:     "confidential-compute-preview",
	SKU:       "16.04-LTS",
}

// DefaultWindowsImage specifies default Windows OS image
var DefaultWindowsImage = OSImage{
	Publisher: "MicrosoftWindowsServer",
	Offer:     "confidential-compute-preview",
	SKU:       "acc-windows-server-2016-datacenter",
}

// AllowedLocations provides supported azure regions
var AllowedLocations = []string{
	"eastus",
	"westeurope",
	"uksouth"
}

// AllowedVMSizes provides supported VM sizes
var AllowedVMSizes = []string{
	"Standard_DC2s",
	"Standard_DC4s",
	"Standard_DC8_v2",
	"Standard_D2s_v3",
	"Standard_D4s_v3",
	"Standard_D8s_v3",
	"Standard_D16s_v3",
	"Standard_D32s_v3",
	"Standard_D64s_v3",
}

// AllowedOsDiskTypes provides supported OS disk types
var AllowedOsDiskTypes = []string{
	"Premium_LRS",
	"StandardSSD_LRS",
	"Standard_LRS",
}

func getAllowedValues(vals []string) string {
	strFormat := `"allowedValues": [
        "%s"
      ],
  `
	return fmt.Sprintf(strFormat, strings.Join(vals, "\",\n        \""))
}

func getDefaultValue(def string) string {
	strFormat := `"defaultValue": "%s",
	`
	return fmt.Sprintf(strFormat, def)
}

func getAllowedDefaultValues(vals []string, def string) string {
	return getAllowedValues(vals) + "    " + getDefaultValue(def)
}

// GetAllowedLocations returns allowed locations
func GetAllowedLocations() string {
	return getAllowedValues(AllowedLocations)
}

// GetAllowedVMSizes returns allowed sizes for VM
func GetAllowedVMSizes() string {
	return getAllowedValues(AllowedVMSizes)
}

// GetOsDiskTypes returns allowed and default OS disk types
func GetOsDiskTypes() string {
	return getAllowedDefaultValues(AllowedOsDiskTypes, DefaultOsDiskType)
}
