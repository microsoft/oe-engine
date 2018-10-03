package api

import (
	"fmt"
	"strings"
)

const (
	// OsUbuntu1604 image
	OsUbuntu1604 = "UbuntuServer_16.04"
	// OsWindows2016 image
	OsWindows2016 = "WindowsServer_2016"
)

const (
	// DefaultVMName is default VM name
	DefaultVMName = "accVM"
	// DefaultGeneratorCode specifies the source generator of the cluster template.
	DefaultGeneratorCode = "oe-engine"
	// DefaultVnet specifies default vnet address space
	DefaultVnet = "10.0.0.0/16"
	// DefaultSubnet specifies default subnet
	DefaultSubnet = "10.0.0.0/24"
	// DefaultOsDiskType specifies default OS disk type
	DefaultOsDiskType = "Premium_LRS"
	// DefaultPackageBaseURL specifies default package base URL
	DefaultPackageBaseURL = "https://oedownload.blob.core.windows.net/data"
	// DefaultLinuxImage specifies default Linux OS image
	DefaultLinuxImage = OsUbuntu1604
	// DefaultWindowsImage specifies default Linux OS image
	DefaultWindowsImage = OsWindows2016
)

// OSImage represents Azure OS Image
type OSImage struct {
	Publisher string
	Offer     string
	SKU       string
	Version   string
	IsWindows bool
}

// OsImageMap contains supported OS images
var OsImageMap = map[string]OSImage{
	OsUbuntu1604: {
		Publisher: "Canonical",
		Offer:     "confidential-compute-preview",
		SKU:       "16.04-LTS",
		Version:   "latest",
		IsWindows: false,
	},
	OsWindows2016: {
		Publisher: "MicrosoftWindowsServer",
		Offer:     "confidential-compute-preview",
		SKU:       "acc-windows-server-2016-datacenter",
		Version:   "latest",
		IsWindows: true,
	},
}

// AllowedLocations provides supported azure regions
var AllowedLocations = []string{
	"eastus",
	"westeurope",
}

// AllowedVMSizes provides supported VM sizes
var AllowedVMSizes = []string{
	"Standard_DC2s",
	"Standard_DC4s",
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

// GetOSImageNames returns allowed and default OS image name
func GetOSImageNames() string {
	osNames := []string{}
	for name := range OsImageMap {
		osNames = append(osNames, name)
	}
	return getAllowedValues(osNames)
}

// GetOSImageReferences returns image references
func GetOSImageReferences() string {
	osRefs := []string{}
	osRefFormat := `  "%s": {
        "publisher": "%s",
        "offer": "%s",
        "sku": "%s",
        "version": "%s"
      }`
	for osname, img := range OsImageMap {
		osRefs = append(osRefs, fmt.Sprintf(osRefFormat, osname, img.Publisher, img.Offer, img.SKU, img.Version))
	}

	strFormat := `"imageReference": {
    %s
  }
  `
	return fmt.Sprintf(strFormat, strings.Join(osRefs, ",\n    "))
}

// GetVMPlans returns VM plans
func GetVMPlans() string {
	vmPlans := []string{}
	vmPlanFormat := `  "%s": {
        "name": "%s",
        "publisher": "%s",
        "product": "%s"
      }`
	for osname, img := range OsImageMap {
		vmPlans = append(vmPlans, fmt.Sprintf(vmPlanFormat, osname, img.SKU, img.Publisher, img.Offer))
	}

	strFormat := `"plans": {
    %s
  }
  `
	return fmt.Sprintf(strFormat, strings.Join(vmPlans, ",\n    "))
}
