package engine

//AzureEndpointConfig describes an Azure endpoint
type AzureEndpointConfig struct {
	ResourceManagerVMDNSSuffix string
}

// KeyVaultID represents a KeyVault instance on Azure
type KeyVaultID struct {
	ID string `json:"id"`
}

// KeyVaultRef represents a reference to KeyVault instance on Azure
type KeyVaultRef struct {
	KeyVault      KeyVaultID `json:"keyVault"`
	SecretName    string     `json:"secretName"`
	SecretVersion string     `json:"secretVersion,omitempty"`
}

type paramsMap map[string]interface{}
