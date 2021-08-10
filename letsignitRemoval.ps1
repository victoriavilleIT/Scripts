$script:is32bits = ([System.IntPtr]::Size -eq 4)

<#
.Description
Write-Logs show the log and save it into the file generated in the function InitLogFile
.Parameter message
The current message to be logged
#>
function Write-Logs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String]$Message
    )
    process {
        $currentDate = Get-Date -UFormat "%Y-%m-%d %H:%M:%S";
        Write-Host "$currentDate | $Message";
        $Message | Out-File -FilePath $script:logFilePath -Append;
    }
}

<#
.Description 
Initialize-Logs generates a new file name and start loging into the file
#>
function Initialize-Logs {
    [CmdletBinding()]
    param()
    process {
        $currentDate = Get-Date -f yyyy-MM-dd_HH_mm_ss;
        $script:logFilePath = "$($env:TEMP)\$($currentDate)` clean-app.log";
        Write-Logs "Start cleaning App script";
        Write-Logs "Powershell version '$($PSVersionTable.PSVersion)'";
        Write-Logs "You can find the complete logs at : '$script:logFilePath'"
    }
}

<#
.Description
Remove-Directory removes directory recursively
.Parameter Path
The path of the directory to remove
#>
function Remove-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$Path
    )
    If (Test-Path $Path) { 
        Remove-Item -Path $Path -Recurse -ErrorAction SilentlyContinue
        Write-Logs "Directory '$($Path)', subfiles and subdirectories removed"
    }
}

<#
.Description
Remove-File removes a specific file
.Parameter Path
The path of the file to remove
#>
function Remove-File {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$Path
    )
    If (Test-Path $Path) { 
        Remove-Item -Path $Path -ErrorAction SilentlyContinue
        Write-Logs "File '$($Path)' removed"
    }   
}

<#
.Description
Remove-RegistryValue removes registry value
.Parameter Path
The path of the registry key to remove
.Parameter Name
The name of the registry value to remove
#>
function Remove-RegistryValue {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$Path,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$Name
    )
    If (Test-Path $Path) { 
        Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue
        Write-Logs "Registry value '$($Name)'removed from '$($Path)'"
    }
}

<#
.Description
Remove-RegistryKey removes registry key
.Parameter Path
The path of the registry key to remove
#>
function Remove-RegistryKey {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$Path
    )
    If (Test-Path $Path) { 
        Remove-Item -Path $Path -Recurse -ErrorAction SilentlyContinue
        Write-Logs "Registry key '$($Path)' removed"
    }
}


<#
.Description
Get-Users retrieve users SID from registry
#>
function Get-Users {
    [OutputType([Array])]
    param()
    process {
        $guSw = [Diagnostics.Stopwatch]::StartNew();
        Write-Logs "Start retrieving users in registry (can take some time)"
        # Can have issues with domain user when not connected to the domain

        $HKU = Get-PSDrive | Where-Object { $_.Root -match "HKEY_USERS" }
        If ($null -eq $HKU) {
            #HKU Provider never used before, create it
            #Assign to a variable to prevent bad return
            $script:PSDrive = New-PSDrive -PSProvider registry -Root HKEY_USERS -Name HKU -Scope Script
        }
        $returnUsers = @((Get-Item "HKU:\" ).GetSubKeyNames() | Where-Object { $_ -notmatch "Classes" -and $_ -match "S-1-5-21"})
        $guSw.Stop();
        Write-Logs "Users retrieved in registry : $($returnUsers.Length) in $($guSw.Elapsed)s"
        return $returnUsers
    }
}

<#
.Description
Clear-Signatures remove Letsignit signatures from Microsoft directory
.Parameter Path
Microsoft directory path
#>
function Clear-Signatures {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$Path
    )
    process {
        $configFile = ("{0}\{1}" -f $Path, "signatures.cfg")
        If (Test-Path $configFile) { 
            $config = Get-Content $configFile -Raw -Encoding "UTF8" | ConvertFrom-Json;
            ForEach ($img in $config.images) {
                Remove-File $img.absolutePath
            }
            ForEach ($user in $config.users.PSObject.Properties) {
                ForEach ($sig in $user.Value.signatures) {
                    Remove-File $sig.signatureFilePath
                }
            }
            Remove-File $configFile
        }
        Else {
            Write-Logs "Cannot remove signatures, configuration file '$configFile' not exists"
        }
    }
}

<#
.Description 
Clear-Directories removes directories and subfiles
#>
function Clear-Directories {
    param ()
    process {
        $clrDirSw = [Diagnostics.Stopwatch]::StartNew();

        # possibles path
        $paths = @("LetsignitApp", "Letsignit App Installer")
        
        ForEach ($path in $paths) {
            #Define Program Files Path
            If ($script:is32bits) {
                $currentPath = "$($env:ProgramFiles)\$($path)"
            }
            Else {
                $currentPath = ${env:ProgramFiles(x86)} + "\$($path)"
            }
            #Remove folders in Program Files
            Remove-Directory -Path $currentPath
        }
        
        #Retrieve AppData users directories
        $usersPath = (Get-Item $env:USERPROFILE).parent.FullName
        
        If (Test-Path $usersPath) {
            ForEach ($user in Get-ChildItem $usersPath | Select-Object Name) {
                $roamingPath = ("{0}\{1}\AppData\{2}\{3}" -f $usersPath, $user.Name, "Roaming", "LetsignitApp")
                $localPath = ("{0}\{1}\AppData\{2}\{3}" -f $usersPath, $user.Name, "Local", "LetsignitApp")
                Remove-Directory -Path $roamingPath
                Remove-Directory -Path $localPath
                $signaturesPath = ("{0}\{1}\AppData\{2}\{3}\{4}" -f $usersPath, $user.Name, "Roaming", "Microsoft", "Signatures")
                Clear-Signatures -Path $signaturesPath
            }
        }
        Else {
            Write-Logs "Can't remove users directories, path '$($usersPath)' not found"
        }

        $clrDirSw.Stop();
        Write-Logs "Clear-Directories done in $($clrDirSw.Elapsed)s";
    }
}

<#
.Description
Clear-InstallerKey removes registry keys corresponding to the installer
.Parameter Path
The path of the registry key to remove
.Parameter Name
The name of the registry value to remove
#>
function Clear-InstallerKey {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$Path,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$Name
    )
    process {
        If (Test-Path -Path $Path) {
            $keyName = (Get-Item $Path) | Get-ChildItem | Where-Object { ($_.GetValue("DisplayName") -and $_.GetValue("DisplayName") -ieq $Name) -or ($_.GetValue("ProductName") -and $_.GetValue("ProductName") -ieq $Name) } | Select-Object PSChildName
            If ($null -ne $keyName) {
                If ($keyName.Length) {
                    ForEach ($key in $keyName) {
                        Remove-RegistryKey -Path ("{0}\{1}" -f $Path, $key.PSChildName)
                    }
                }
                Else {
                    Remove-RegistryKey -Path ("{0}\{1}" -f $Path, $keyName.PSChildName)
                }
            }
        }
    }
}

<#
.Description
Clear-Registry removes registry keys
#>
function Clear-Registry {
    param ()
    process {
        $clrRegSw = [Diagnostics.Stopwatch]::StartNew();

        If (!$script:is32bits) {
            Remove-RegistryValue -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "LetsignitAppMachineInstaller"
            Remove-RegistryValue -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "LetsignitApp"
        }
        Remove-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "LetsignitAppMachineInstaller"
        Remove-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "LetsignitApp"
        Remove-RegistryKey -Path "HKLM:\Software\Letsignitapp\Setup"

        $users = @(Get-Users)
        ForEach ($user in $users) {
            $CurrentUser = ("HKU:\{0}" -f $user)
            $installerPaths = @("$($CurrentUser)\Software\Microsoft\Windows\CurrentVersion\Uninstall", 
                "$($CurrentUser)\Software\Microsoft\Installer\Products")

            If (!$script:is32bits) {
                Remove-RegistryValue -Path "$($CurrentUser)\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "Letsignit App"
                $installerPaths += "$($CurrentUser)\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
                $installerPaths += "$($CurrentUser)\Software\Wow6432Node\Microsoft\Installer\Products"
            }
            Remove-RegistryValue -Path "$($CurrentUser)\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Letsignit App"
            Remove-RegistryKey -Path "$($CurrentUser)\Software\Letsignit\LetsignitApp"

            ForEach ($path in $installerPaths) {
                Clear-InstallerKey -Path $path -Name "Letsignit App"
                Clear-InstallerKey -Path $path -Name "Letsignit App Machine-Wide Installer"
            }
        }

        $installerPaths = @("HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall", 
            "HKLM:\Software\Classes\Installer\Products",
            "HKCR:\Installer\Products")

        If (!$script:is32bits) {
            $installerPaths += "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
            $installerPaths += "HKLM:\Software\Wow6432Node\Classes\Installer\Products"
        }

        ForEach ($path in $installerPaths) {
            Clear-InstallerKey -Path $path -Name "Letsignit App Machine-Wide"
        }

        $clrRegSw.Stop();
        Write-Logs "Clear-Registry done in $($clrRegSw.Elapsed)s";
    }
}


$script:stopWatch = [Diagnostics.Stopwatch]::StartNew()

Initialize-Logs;
Clear-Registry;
Clear-Directories;

$script:stopWatch.Stop();
Write-Logs "Cleaned app in $($script:stopWatch.Elapsed)";
