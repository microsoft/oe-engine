package api

const (
	OsUbuntu1604  = "UbuntuServer_16.04"
	OsWindows2016 = "WindowsServer_2016"

	OsImageDefault = OsUbuntu1604
)

// OSImage represent Azure OS Image
type OSImage struct {
	Publisher string
	Offer     string
	SKU       string
	Version   string
	IsWindows bool
}

var OsImageMap map[string]OSImage

func init() {
	OsImageMap = map[string]OSImage{
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
}
