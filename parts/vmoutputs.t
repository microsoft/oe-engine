  "{{.Name}}FQDN": {
    "type": "string",
{{if HasDNSName .}}
    "value": "[reference(concat('Microsoft.Network/publicIPAddresses/', variables('{{.Name}}PublicIPAddressName'))).dnsSettings.fqdn]"
{{else}}
    "value": ""
{{end}}
  },
