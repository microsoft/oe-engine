    "masterFQDN": {
      "type": "string",
{{if not IsPrivateCluster}}
      "value": "[reference(concat('Microsoft.Network/publicIPAddresses/', variables('masterPublicIPAddressName'))).dnsSettings.fqdn]"
{{else}}
      "value": ""
{{end}}
    }
