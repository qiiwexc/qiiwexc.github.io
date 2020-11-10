Function Get-SystemInfo {
    Add-Log $INF 'Gathering system information...'

    Set-Variable -Option Constant OperatingSystem (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version)

    Set-Variable -Option Constant -Scope Script OS_NAME $OperatingSystem.Caption
    Set-Variable -Option Constant -Scope Script OS_BUILD $OperatingSystem.Version
    Set-Variable -Option Constant -Scope Script OS_64_BIT $(if ($OperatingSystem.OSArchitecture -Like '64-*') { $True })
    Set-Variable -Option Constant -Scope Script OS_VERSION $(Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } })

    Set-Variable -Option Constant -Scope Script CURRENT_DIR $(Split-Path $MyInvocation.ScriptName)
    Set-Variable -Option Constant -Scope Script PROGRAM_FILES_86 $(if ($OS_64_BIT) { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles })

    New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
    Set-Variable -Option Constant WordRegPath (Get-ItemProperty 'HKCR:\Word.Application\CurVer' -ErrorAction SilentlyContinue)
    Set-Variable -Option Constant -Scope Script OfficeVersion $(if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' })
    Set-Variable -Option Constant -Scope Script OfficeC2RClientExe "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
    Set-Variable -Option Constant -Scope Script OfficeInstallType $(if ($OfficeVersion) { if (Test-Path $OfficeC2RClientExe) { 'C2R' } else { 'MSI' } })

    Set-Variable -Option Constant -Scope Script CCleanerExe "$env:ProgramFiles\CCleaner\CCleaner$(if ($OS_64_BIT) {'64'}).exe"
    Set-Variable -Option Constant -Scope Script DefragglerExe "$env:ProgramFiles\Defraggler\df$(if ($OS_64_BIT) {'64'}).exe"
    Set-Variable -Option Constant -Scope Script DefenderExe "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    Set-Variable -Option Constant -Scope Script ChromeExe "$PROGRAM_FILES_86\Google\Chrome\Application\chrome.exe"

    Set-Variable -Option Constant LogicalDisk (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID = 'C:'")
    Set-Variable -Option Constant -Scope Script SystemPartition ($LogicalDisk | Select-Object @{L = 'FreeSpace'; E = { '{0:N2}' -f ($_.FreeSpace / 1GB) } }, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } })

    Out-Success
}


Function Out-SystemInfo {
    Add-Log $INF 'Current system information:'
    Add-Log $INF '  Hardware'

    Set-Variable -Option Constant ComputerSystem (Get-WmiObject Win32_ComputerSystem)
    Set-Variable -Option Constant Computer ($ComputerSystem | Select-Object Manufacturer, Model, SystemSKUNumber, PCSystemType, @{L = 'RAM'; E = { '{0:N2}' -f ($_.TotalPhysicalMemory / 1GB) } })
    if ($Computer) {
        Add-Log $INF "    Computer type:  $(Switch ($Computer.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
        Add-Log $INF "    Computer model:  $($Computer.Manufacturer) $($Computer.Model) $(if ($Computer.SystemSKUNumber) {"($($Computer.SystemSKUNumber))"})"
        Add-Log $INF "    RAM:  $($Computer.RAM) GB"
    }

    [Array]$Processors = (Get-WmiObject Win32_Processor | Select-Object Name)
    if ($Processors) {
        ForEach ($Item In $Processors) {
            Add-Log $INF "    CPU $([Array]::IndexOf($Processors, $Item)) Name:  $($Item.Name)"
        }
    }

    [Array]$VideoControllers = ((Get-WmiObject Win32_VideoController).Name)
    if ($VideoControllers) { ForEach ($Item In $VideoControllers) { Add-Log $INF "    GPU $([Array]::IndexOf($VideoControllers, $Item)):  $Item" } }

    if ($OS_VERSION -gt 7) {
        [Array]$Storage = (Get-PhysicalDisk | Select-Object BusType, FriendlyName, HealthStatus, MediaType, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } })
        if ($Storage) {
            ForEach ($Item In $Storage) {
                $Details = "$($Item.BusType)$(if ($Item.MediaType -ne 'Unspecified') {' ' + $Item.MediaType}), $($Item.Size) GB, $($Item.HealthStatus)"
                Add-Log $INF "    Storage $([Array]::IndexOf($Storage, $Item)):  $($Item.FriendlyName) ($Details)"
            }
        }
    }
    else {
        [Array]$Storage = (Get-WmiObject Win32_DiskDrive | Select-Object Model, Status, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } })
        if ($Storage) { ForEach ($Item In $Storage) { Add-Log $INF "    Storage:  $($Item.Model) ($($Item.Size) GB, Health: $($Item.Status))" } }
    }

    if ($SystemPartition) {
        Add-Log $INF "    Free space on system partition: $($SystemPartition.FreeSpace) GB / $($SystemPartition.Size) GB ($((Get-FreeDiskSpace).ToString('P')))"
    }

    Set-Variable -Option Constant OfficeYear $(Switch ($OfficeVersion) { 16 { '2016 / 2019' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } })
    Set-Variable -Option Constant OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' })
    Set-Variable -Option Constant Win10Release ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId)

    Add-Log $INF '  Software'
    Add-Log $INF "    BIOS version:  $((Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion)"
    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $(if ($OS_64_BIT) { '64-bit' } else { '32-bit' })"
    Add-Log $INF "    $(if ($OS_VERSION -eq 10) {'OS release / '})Build number:  $(if ($OS_VERSION -eq 10) {"v$Win10Release / "})$OS_BUILD"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OfficeInstallType) {`"($OfficeInstallType installation type)`"})"
    Add-Log $INF "    PowerShell version:  $PS_VERSION.$($PSVersionTable.PSVersion.Minor)"

    Set-ButtonState
}
