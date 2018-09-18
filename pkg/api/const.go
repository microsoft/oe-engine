package api

import (
	"fmt"
	"strings"
)

const (
	OsUbuntu1604  = "UbuntuServer_16.04"
	OsWindows2016 = "WindowsServer_2016"

	OsImageDefault = OsUbuntu1604
)

const (
	// DefaultVMName is default VM name
	DefaultVMName = "accVM"
	// DefaultGeneratorCode specifies the source generator of the cluster template.
	DefaultGeneratorCode = "oe-engine"
	// DefaultStaticIP specifies default static IP address
	DefaultStaticIP = "10.0.0.4"
	// DefaultSubnet specifies default subnet
	DefaultSubnet = "10.0.0.0/24"
	// DefaultStorageAccountType specifies default storage account type
	DefaultStorageAccountType = "Premium_LRS"
	// DefaultPackageBaseURL specifies default package base URL
	DefaultPackageBaseURL = "https://oedownload.blob.core.windows.net/binaries"
	// DefaultOSDiskSizeGB specifies default OS disk size
	DefaultOSDiskSizeGB = 30
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
		Publisher: "microsoft-azure-compute",
		Offer:     "azureconfidentialcompute",
		SKU:       "acc-ubuntu-16",
		Version:   "latest",
		IsWindows: false,
	},
	OsWindows2016: {
		Publisher: "MicrosoftWindowsServer",
		Offer:     "WindowsServer",
		SKU:       "2016-Datacenter",
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

// AllowedStorageAccountTypes provides supported storage account types
var AllowedStorageAccountTypes = []string{
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
	return getAllowedValues(vals) + getDefaultValue(def)
}

// GetAllowedLocations returns allowed locations
func GetAllowedLocations() string {
	return getAllowedValues(AllowedLocations)
}

// GetAllowedVMSizes returns allowed sizes for VM
func GetAllowedVMSizes() string {
	return getAllowedValues(AllowedVMSizes)
}

// GetStorageAccountTypes returns allowed and default storage account types
func GetStorageAccountTypes() string {
	return getAllowedDefaultValues(AllowedStorageAccountTypes, DefaultStorageAccountType)
}

// GetOSImageNames returns allowed and default OS image name
func GetOSImageNames() string {
	osNames := []string{}
	for name := range OsImageMap {
		osNames = append(osNames, name)
	}
	return getAllowedDefaultValues(osNames, OsImageDefault)
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
	for osname, img := range OsImageMap {
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
	img, ok := OsImageMap[osImageName]
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
