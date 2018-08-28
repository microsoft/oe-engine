package engine

// AzureLocations provides all azure regions in prod.
// Related powershell to refresh this list:
//   Get-AzureRmLocation | Select-Object -Property Location
var AzureLocations = []string{
	"eastus",
}

// GetAgentAllowedSizes returns the agent allowed sizes
func GetAgentAllowedSizes() string {
	return `      "allowedValues": [
        "Standard_DC2",
        "Standard_DC4",
        "Standard_B1s"
        ],
        `
}

// GetSizeMap returns the size / storage map
func GetSizeMap() string {
	return `    "vmSizesMap": {
    "Standard_A0": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A1": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A10": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A11": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A1_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A2_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A2m_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A4": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A4_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A4m_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A5": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A6": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A7": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A8": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A8_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A8m_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_A9": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_B1ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_B1s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_B2ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_B2s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_B4ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_B8ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_D1": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D11": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D11_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D11_v2_Promo": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D12": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D12_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D12_v2_Promo": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D13": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D13_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D13_v2_Promo": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D14": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D14_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D14_v2_Promo": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D15_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D16_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D16s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_D1_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D2_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D2_v2_Promo": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D2_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D2s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_D3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D32_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D32s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_D3_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D3_v2_Promo": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D4": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D4_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D4_v2_Promo": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D4_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D4s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_D5_v2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D5_v2_Promo": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D64_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D64s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_D8_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_D8s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS1": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS11": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS11-1_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS11_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS11_v2_Promo": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS12": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS12-1_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS12-2_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS12_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS12_v2_Promo": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS13": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS13-2_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS13-4_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS13_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS13_v2_Promo": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS14": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS14-4_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS14-8_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS14_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS14_v2_Promo": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS15_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS1_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS2_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS2_v2_Promo": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS3_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS3_v2_Promo": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS4": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS4_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS4_v2_Promo": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS5_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_DS5_v2_Promo": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E16-4s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E16-8s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E16_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_E16s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E2_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_E2s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E32-16s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E32-8s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E32_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_E32s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E4-2s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E4_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_E4s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E64-16s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E64-32s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E64_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_E64i_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_E64is_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E64s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E8-2s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E8-4s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_E8_v3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_E8s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F1": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_F16": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_F16s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F16s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F1s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_F2s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F2s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F32s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F4": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_F4s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F4s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F64s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F72s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F8": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_F8s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_F8s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_G1": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_G2": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_G3": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_G4": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_G5": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_GS1": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_GS2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_GS3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_GS4": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_GS4-4": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_GS4-8": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_GS5": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_GS5-16": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_GS5-8": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_H16": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_H16m": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_H16mr": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_H16r": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_H8": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_H8m": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_L16s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_L16s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_L32s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_L4s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_L8s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_L8s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M128": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_M128-32ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M128-64ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M128m": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_M128ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M128s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M16-4ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M16-8ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M16ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M32-16ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M32-8ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M32ls": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M32ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M32ts": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M64": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_M64-16ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M64-32ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M64ls": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M64m": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_M64ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M64s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M8-2ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M8-4ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_M8ms": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_NC12": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_NC12s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_NC12s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_NC24": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_NC24r": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_NC24rs_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_NC24rs_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_NC24s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_NC24s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_NC6": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_NC6s_v2": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_NC6s_v3": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_ND12s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_ND24rs": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_ND24s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_ND6s": {
      "storageAccountType": "Premium_LRS"
    },
    "Standard_NV12": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_NV24": {
      "storageAccountType": "Standard_LRS"
    },
    "Standard_NV6": {
      "storageAccountType": "Standard_LRS"
    }
   }
`
}
