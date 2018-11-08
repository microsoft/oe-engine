    "vnetSubnetID": "[resourceId(parameters('vnetResourceGroupName'), 'Microsoft.Network/virtualNetworks/subnets/', parameters('vnetName'), parameters('subnetName'))]",
    "linuxConfiguration": {
      "disablePasswordAuthentication": "true",
      "ssh": {{GetLinuxPublicKeys}}
    },
    "singleQuote": "'",
    "windowsConfiguration": {
      "provisionVmAgent": "true"
    },
    "diagnosticsStorageAction": "[if(equals(parameters('bootDiagnostics'), 'disable'), 'nop', parameters('diagnosticsStorageAccountNewOrExisting'))]",
    "winScriptSuffix": " $inputFile = '\\AzureData\\CustomData.bin' ; $outputFile = '\\AzureData\\oeWindowsProvision.ps1' ; $inputStream = New-Object System.IO.FileStream $inputFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read) ; $sr = New-Object System.IO.StreamReader(New-Object System.IO.Compression.GZipStream($inputStream, [System.IO.Compression.CompressionMode]::Decompress)) ; $sr.ReadToEnd() | Out-File($outputFile) ; &$outputFile ; ",
    "winScriptArguments": "[concat('$arguments = ', variables('singleQuote'),' ',variables('singleQuote'), ' ; ')]",
    "windowsExtScript": "[concat('powershell.exe -ExecutionPolicy Unrestricted -command \"', variables('winScriptSuffix'), '\" > \\AzureData\\provisionScript.log 2>&1; exit $LASTEXITCODE')]"
