{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    {{range .VMProfiles}}
      {{template "vmparams.t" .}}
    {{end}}
    {{template "params.t" .}}
  },
  "variables": {
    {{range $index, $vm := .VMProfiles}}
      "{{.Name}}Index": {{$index}},
      {{template "vmvars.t" .}}
    {{end}}
    {{template "vars.t" .}}
  },
  "resources": [
    {{range $index, $vm := .VMProfiles}}
      {{template "vmresources.t" .}}
    {{end}}
    {{template "resources.t" .}}
  ],
  "outputs": {
    {{template "outputs.t" .}}
  }
}
