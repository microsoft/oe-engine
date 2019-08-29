# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = "Stop"

$IS_VANILLA = "IS_VANILLA_VM"
$PACKAGES_DIRECTORY = Join-Path $env:TEMP "packages"
$PACKAGES_NAMES_VANILLA = @("7z", "git", "openssh")
$PACKAGES = @{
    "AzureDCAP" = @{
        "url" = "https://www.nuget.org/api/v2/package/Azure.DCAP.Windows/0.0.2"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "azure.dcap.windows.0.0.2.nupkg"
        "renamed_file" = Join-Path $PACKAGES_DIRECTORY "azure.dcap.windows.0.0.2.zip"
    }
    "7z" = @{
        "url" = "https://www.7-zip.org/a/7z1805-x64.msi"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "7z1805-x64.msi"
    }
    "nuget" = @{
        "url" = "https://dist.nuget.org/win-x86-commandline/v4.1.0/nuget.exe"
        "local_file" = Join-Path ${PACKAGES_DIRECTORY} "nuget.exe"
    }
}


filter Timestamp { "[$(Get-Date -Format o)] $_" }


function Write-Log {
    Param(
        [string]$Message
    )
    $msg = $Message | Timestamp
    Write-Output $msg
}


function New-Directory {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$false)]
        [switch]$RemoveExisting
    )
    if(Test-Path $Path) {
        if($RemoveExisting) {
            # Remove if it already exist
            Remove-Item -Recurse -Force $Path
        } else {
            return
        }
    }
    return (New-Item -ItemType Directory -Path $Path)
}


function Start-LocalPackagesDownload {
    Write-Output "Downloading all the packages to local directory: $PACKAGES_DIRECTORY"
    New-Directory ${PACKAGES_DIRECTORY}
    foreach($pkg in $PACKAGES.Keys) {
        if(!($pkg -in $PACKAGES_NAMES_VANILLA) -and ($IS_VANILLA -eq "true")) {
            Write-Output "Skipping $PACKAGES[$pkg]["local_file"] on Vanilla VM"
            continue
        }
        Write-Output "Downloading: $($PACKAGES[$pkg]["url"])"
        Start-FileDownload -URL $PACKAGES[$pkg]["url"] `
                           -Destination $PACKAGES[$pkg]["local_file"]
    }
    Write-Output "Finished downloading all the packages"
}


function Start-ExecuteWithRetry {
    Param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock]$ScriptBlock,
        [int]$MaxRetryCount=10,
        [int]$RetryInterval=3,
        [string]$RetryMessage,
        [array]$ArgumentList=@()
    )
    $currentErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $retryCount = 0
    while ($true) {
        Write-Log "Start-ExecuteWithRetry attempt $retryCount"
        try {
            $res = Invoke-Command -ScriptBlock $ScriptBlock `
                                  -ArgumentList $ArgumentList
            $ErrorActionPreference = $currentErrorActionPreference
            Write-Log "Start-ExecuteWithRetry terminated"
            return $res
        } catch [System.Exception] {
            $retryCount++
            if ($retryCount -gt $MaxRetryCount) {
                $ErrorActionPreference = $currentErrorActionPreference
                Write-Log "Start-ExecuteWithRetry exception thrown"
                throw
            } else {
                if($RetryMessage) {
                    Write-Log "Start-ExecuteWithRetry RetryMessage: $RetryMessage"
                } elseif($_) {
                    Write-Log "Start-ExecuteWithRetry Retry: $_.ToString()"
                }
                Start-Sleep $RetryInterval
            }
        }
    }
}


function Start-FileDownload {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$URL,
        [Parameter(Mandatory=$true)]
        [string]$Destination,
        [Parameter(Mandatory=$false)]
        [int]$RetryCount=10
    )
    Start-ExecuteWithRetry -ScriptBlock {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($URL,$Destination)
    } -MaxRetryCount $RetryCount -RetryInterval 3 -RetryMessage "Failed to download ${URL}. Retrying"
}


function Add-ToSystemPath {
    Param(
        [Parameter(Mandatory=$false)]
        [string[]]$Path
    )
    if(!$Path) {
        return
    }
    $systemPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine').Split(';')
    $currentPath = $env:PATH.Split(';')
    foreach($p in $Path) {
        if($p -notin $systemPath) {
            $systemPath += $p
        }
        if($p -notin $currentPath) {
            $currentPath += $p
        }
    }
    $env:PATH = $currentPath -join ';'
    setx.exe /M PATH ($systemPath -join ';')
    if($LASTEXITCODE) {
        Throw "Failed to set the new system path"
    }
}

function Install-Tool {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$InstallerPath,
        [Parameter(Mandatory=$false)]
        [string]$InstallDirectory,
        [Parameter(Mandatory=$false)]
        [string[]]$ArgumentList,
        [Parameter(Mandatory=$false)]
        [string[]]$EnvironmentPath
    )
    if($InstallDirectory -and (Test-Path $InstallDirectory)) {
        Write-Output "$InstallerPath is already installed."
        Add-ToSystemPath -Path $EnvironmentPath
        return
    }
    $parameters = @{
        'FilePath' = $InstallerPath
        'Wait' = $true
        'PassThru' = $true
    }
    if($ArgumentList) {
        $parameters['ArgumentList'] = $ArgumentList
    }
    if($InstallerPath.EndsWith('.msi')) {
        $parameters['FilePath'] = 'msiexec.exe'
        $parameters['ArgumentList'] = @("/i", $InstallerPath) + $ArgumentList
    }
    Write-Output "Installing $InstallerPath"
    $p = Start-Process @parameters
    if($p.ExitCode -ne 0) {
        Throw "Failed to install: $InstallerPath"
    }
    Add-ToSystemPath -Path $EnvironmentPath
    Write-Output "Successfully installed: $InstallerPath"
}


function Install-ZipTool {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ZipPath,
        [Parameter(Mandatory=$true)]
        [string]$InstallDirectory,
        [Parameter(Mandatory=$false)]
        [string[]]$EnvironmentPath
    )
    if(Test-Path $InstallDirectory) {
        Write-Output "$ZipPath is already installed."
        Add-ToSystemPath -Path $EnvironmentPath
        return
    }
    New-Item -ItemType "Directory" -Path $InstallDirectory
    7z.exe x $ZipPath -o"$InstallDirectory" -y
    if($LASTEXITCODE) {
        Throw "ERROR: Failed to extract $ZipPath to $InstallDirectory"
    }
    Add-ToSystemPath $EnvironmentPath
}

function Install-7Zip {
    $installDir = Join-Path $env:ProgramFiles "7-Zip"
    Install-Tool -InstallerPath $PACKAGES["7z"]["local_file"] `
                 -InstallDirectory $installDir `
                 -ArgumentList @("/quiet", "/passive") `
                 -EnvironmentPath @($installDir)
}

function Install-AzureDCAP{
    $installDir = Join-Path $PACKAGES_DIRECTORY "AzureDCAP"
    $DCAPlocation =  "$env:windir\System32"
    Rename-item -Path $PACKAGES["AzureDCAP"]["local_file"] -NewName $PACKAGES["AzureDCAP"]["renamed_file"]
    Install-ZipTool $PACKAGES["AzureDCAP"]["renamed_file"] `
                    -InstallDirectory $installDir
    $p = Start-Process powershell -Wait -NoNewWindow -PassThru -argument "$installDir\script\InstallAzureDCAP.ps1 $DCAPlocation" -WorkingDirectory "$installDir\script"
    if($p.ExitCode -ne 0) {
        Throw "Failed to Add Azure-DCAPLibrary. Please Add it manually."
    }

}

function Add-RegistrySettings {
    $AddingRegistryCMD = @"
    reg query HKLM\SYSTEM\CurrentControlSet\Services\sgx_lc_msr\Parameters /v SGX_Launch_Config_Optin
    if %ERRORLEVEL% EQU 1 goto SETUP
    REG QUERY HKLM\SYSTEM\CurrentControlSet\Services\sgx_lc_msr\Parameters\ /t REG_DWORD /f 1
    if %ERRORLEVEL% EQU 1 goto SETUP
    goto:eof
    :SETUP
    reg add HKLM\SYSTEM\CurrentControlSet\Services\sgx_lc_msr\Parameters /f /v SGX_Launch_Config_Optin /t REG_DWORD /d 0x01
    SHUTDOWN -r -t 60
"@
    $CurrentDir = (Get-Location).Path
    $CMDFileName = "$CurrentDir\AddRegistry.cmd"
    $AddingRegistryCMD | Out-File -FilePath $CMDFileName -Encoding ASCII
    $p = Start-Process 'cmd' -ArgumentList "/c $CMDFileName" -Verb RunAs -PassThru -Wait -WarningAction SilentlyContinue
    Remove-Item -Path $CMDFileName
    if($p.ExitCode -ne 0) {
            Throw "Failed to Add Opt-in Registry settings. Please Add it manually."
        }
}

try {
    Start-LocalPackagesDownload
    Install-7Zip
    Install-AzureDCAP
    Add-RegistrySettings
}catch {
    Write-Output $_.ToString()
    Write-Output $_.ScriptStackTrace
    exit 1
}
exit 0
