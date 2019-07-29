# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = "Stop"

$IS_VANILLA = "IS_VANILLA_VM"
$AZUREDATA_DIRECTORY = Join-Path ${env:SystemDrive} "AzureData"
$AZUREDATA_BIN_DIRECTORY = Join-Path $AZUREDATA_DIRECTORY "bin"
$PACKAGES_DIRECTORY = Join-Path $env:TEMP "packages"
$PACKAGES_NAMES_VANILLA = @("7z", "git", "openssh")
$PACKAGES = @{
    "openssh" = @{
        "url" = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v7.7.2.0p1-Beta/OpenSSH-Win64.zip"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "OpenSSH-Win64.zip"
    }
    "AzureDCAP" = @{
        "url" = "https://www.nuget.org/api/v2/package/Azure.DCAP.Windows/0.0.1"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "azure.dcap.windows.0.0.1.nupkg"
        "renamed_file" = Join-Path $PACKAGES_DIRECTORY "azure.dcap.windows.0.0.1.zip"
    }
    
    "git" = @{
        "url" = "https://github.com/git-for-windows/git/releases/download/v2.19.1.windows.1/Git-2.19.1-64-bit.exe"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "git-2.19.1-64-bit.exe"
    }
    "7z" = @{
        "url" = "https://www.7-zip.org/a/7z1805-x64.msi"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "7z1805-x64.msi"
    }
    "vs_buildtools" = @{
        "url" = "https://aka.ms/vs/15/release/vs_buildtools.exe"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "vs_buildtools.exe"
    }
    "cmake" = @{
        "url" = "https://cmake.org/files/v3.13/cmake-3.13.0-rc1-win64-x64.msi"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "cmake-3.13.0-rc1-win64-x64.msi"
    }
    "ocaml" = @{
        "url" = "http://www.ocamlpro.com/pub/ocpwin/ocpwin-builds/ocpwin64/20160113/ocpwin64-20160113-4.02.1+ocp1-msvc64.zip"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "ocpwin64.zip"
    }
    "sgx_drivers" = @{
        "url" = "http://download.windowsupdate.com/d/msdownload/update/driver/drvs/2018/01/af564f2c-2bc5-43be-a863-437a5a0008cb_61e7ba0c2e17c87caf4d5d3cdf1f35f6be462b38.cab"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "sgx_base.cab"
    }
    "psw" = @{
        "url" = "https://oejenkins.blob.core.windows.net/oejenkins/Intel_SGX_PSW_for_Windows_v2.3.100.49777.exe"
        "local_file" = Join-Path $PACKAGES_DIRECTORY "Intel_SGX_PSW_for_Windows_v2.3.100.49777.exe"
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


function Install-OpenSSH()
{
    $sshPubKey = "SSH_PUB_KEY"
    if (!$sshPubKey) {
        Write-Output "SSH public key is omitted. Skipping OpenSSH installation."
        return
    }
    Write-Output "Installing OpenSSH"

    try {
        $rslt = ( get-service | where { $_.name -like "sshd" } )
        if ($rslt.count -eq 0) {
            $list = (Get-WindowsCapability -Online | ? Name -like 'OpenSSH.Server*')
            if ($list) {
                Add-WindowsCapability -Online -Name $list.Name
                Install-PackageProvider -Name "NuGet" -Force
                Install-Module -Force OpenSSHUtils
            } else {
                $installDir = Join-Path $env:ProgramFiles "OpenSSH"
                Install-ZipTool -ZipPath $PACKAGES["openssh"]["local_file"] `
                                -InstallDirectory $installDir
                & "$installDir/OpenSSH-Win64/install-sshd.ps1"
                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to install OpenSSH"
                }
            }
        }

        Start-Service sshd
        New-NetFirewallRule -Name "ssh-tcp-rule" -DisplayName "SSH TCP Port 22" `
                            -LocalPort 22 -Action Allow -Enabled True `
                            -Direction Inbound -Protocol TCP -Profile Any

        Write-Output "Creating authorized key"
        $publicKeysFile = Join-Path $AZUREDATA_DIRECTORY "authorized_keys"
        Set-Content -Path $publicKeysFile -Value $sshPubKey -Encoding Ascii

        $sshdConfigFile = Join-Path $env:ProgramData "ssh\sshd_config"
        $newSshdConfig = (Get-Content $sshdConfigFile) -replace "AuthorizedKeysFile(\s+).*$", "AuthorizedKeysFile $publicKeysFile"
        Set-Content -Path $sshdConfigFile -Value $newSshdConfig -Encoding ascii
        $acl = Get-Acl -Path $publicKeysFile
        $acl.SetAccessRuleProtection($True, $True)
        $acl | Set-Acl -Path $publicKeysFile

        $acl = Get-Acl -Path $publicKeysFile
        $rules = $acl.Access
        $usersToRemove = @("Everyone","BUILTIN\Users","NT AUTHORITY\Authenticated Users")
        foreach ($u in $usersToRemove) {
            $targetrule = $rules | where IdentityReference -eq $u
            if ($targetrule) {
                $acl.RemoveAccessRule($targetrule)
            }
        }
        $acl | Set-Acl -Path $publicKeysFile

        Restart-Service sshd
        Set-Service -Name "sshd" -StartupType Automatic
    }
    catch {
       Write-Output "OpenSSH install failed: $_"
    }
}


function Install-Git {
    $installDir = Join-Path $env:ProgramFiles "Git"
    Install-Tool -InstallerPath $PACKAGES["git"]["local_file"] `
                 -InstallDirectory $installDir `
                 -ArgumentList @("/SILENT") `
                 -EnvironmentPath @("$installDir\cmd", "$installDir\bin", "$installDir\mingw64\bin")

}


function Install-7Zip {
    $installDir = Join-Path $env:ProgramFiles "7-Zip"
    Install-Tool -InstallerPath $PACKAGES["7z"]["local_file"] `
                 -InstallDirectory $installDir `
                 -ArgumentList @("/quiet", "/passive") `
                 -EnvironmentPath @($installDir)
}


function Install-SGX {
    $installDir = Join-Path $PACKAGES_DIRECTORY "sgx_base"
    Install-ZipTool -ZipPath $PACKAGES["sgx_drivers"]["local_file"] `
                    -InstallDirectory $installDir
    pnputil /add-driver "$installDir\sgx_base.inf"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install SGX Drivers"
    }
}


function Install-PSW {
    $installDir = Join-Path $PACKAGES_DIRECTORY "intel_psw_install"
    Install-ZipTool -ZipPath $PACKAGES["psw"]["local_file"] `
                    -InstallDirectory $installDir

    $pswInstaller = Join-Path $installDir "Intel SGX PSW for Windows v2.3.100.49777\PSW_EXE_RS2_and_before\Intel(R)_SGX_Windows_x64_PSW_2.3.100.49777.exe"
    $p = Start-Process -Wait -NoNewWindow -PassThru -FilePath $pswInstaller `
                       -ArgumentList @("--extract-folder", "$installDir", "--x")
    if($p.ExitCode -ne 0) {
        Throw "Failed to extract the Intel SGX PSW bundle: $pswInstaller"
    }
    $p = Start-Process -Wait -NoNewWindow -PassThru -FilePath "$installDir\install.exe" `
                       -ArgumentList @("install", "--eula=accept", "--output=$installDir\intel_install.log", "--components=all")
    if($p.ExitCode -ne 0) {
        Throw "Failed to install the Intel SGX PSW software"
    }
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
    SHUTDOWN -r -t 10
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

function Install-VisualStudio {
    $installerArguments = @(
        "-q", "--wait", "--norestart", "--nocache",
        "--add Microsoft.VisualStudio.Workload.MSBuildTools",
        "--add Microsoft.VisualStudio.Workload.VCTools",
        "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
        "--add Microsoft.VisualStudio.Component.VC.140",
        "--add Microsoft.VisualStudio.Component.Windows10SDK.16299.Desktop",
        "--add Microsoft.VisualStudio.Component.Windows81SDK",
        "--add Microsoft.VisualStudio.Component.VC.ATL"
    )
    # VisualStudio install sometimes is throwing errors on first try.
    Start-ExecuteWithRetry -ScriptBlock {
       Install-Tool -InstallerPath $PACKAGES["vs_buildtools"]["local_file"] `
                    -ArgumentList $installerArguments
    } -RetryMessage "Failed to install Visual Studio. Retrying"

    [Environment]::SetEnvironmentVariable("VS150COMNTOOLS", "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2017\BuildTools\Common7\Tools", "Machine")
}

function Install-Cmake {
    $installDir = Join-Path $env:ProgramFiles "CMake"

    Install-Tool -InstallerPath $PACKAGES["cmake"]["local_file"] `
                 -InstallDirectory $installDir `
                 -ArgumentList @("/quiet", "/passive") `
                 -EnvironmentPath @("$installDir\bin")

}

function Install-Ocaml {
    $installDir = Join-Path $env:ProgramFiles "ocpwin64"
    $tmpDir = Join-Path $PACKAGES_DIRECTORY "ocpwin64"
    Install-ZipTool -ZipPath $PACKAGES["ocaml"]["local_file"] `
                    -InstallDirectory $tmpDir `
                    -EnvironmentPath @("$installDir\bin")
    New-Directory -Path $installDir -RemoveExisting
    Move-Item -Path "$tmpDir\*\*" -Destination $installDir
    Push-Location $installDir
    ocpwin -in
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install ocaml"
    }
    Pop-Location
}


try {
    New-Directory -Path ${AZUREDATA_DIRECTORY}
    New-Directory -Path ${AZUREDATA_BIN_DIRECTORY}

    Start-LocalPackagesDownload
    Install-Git
    Install-7Zip
    Install-OpenSSH

    if ($IS_VANILLA -eq "true") {
        Write-Output "Skipping Open Enclave installation."
        exit 0
    }
    Write-Output "Installing Open Enclave"
    Install-SGX
    Install-PSW
    Install-AzureDCAP
    Add-RegistrySettings
    
    Start-ExecuteWithRetry -ScriptBlock {
        Start-Service "AESMService" -ErrorAction Stop
    } -RetryMessage "Failed to start AESMService. Retrying"

    Copy-Item -Path $PACKAGES["nuget"]["local_file"] -Destination "${AZUREDATA_BIN_DIRECTORY}\nuget.exe"

    Install-VisualStudio
    Install-Cmake
    Install-Ocaml
}catch {
    Write-Output $_.ToString()
    Write-Output $_.ScriptStackTrace
    exit 1
}
exit 0
