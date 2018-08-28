{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    {{template "params.t" .}}
  },
  "variables": {
    {{template "vars.t" .}}
  },
  "resources": [
    {{template "resources.t" .}}
  ],
  "outputs": {
    {{template "outputs.t" .}}
  }
}
