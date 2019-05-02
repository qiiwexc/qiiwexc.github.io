function Get-SystemInfo {
    Add-Log $INF 'Gathering system information...'

    Set-Variable OperatingSystem (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version) -Option Constant

    Set-Variable OS_NAME $OperatingSystem.Caption -Option Constant -Scope Script
    Set-Variable OS_BUILD $OperatingSystem.Version -Option Constant -Scope Script
    Set-Variable OS_ARCH $(if ($OperatingSystem.OSArchitecture -like '64-*') { '64-bit' } else { '32-bit' }) -Option Constant -Scope Script
    Set-Variable OS_VERSION $(Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } }) -Option Constant -Scope Script

    Set-Variable CURRENT_DIR $(Split-Path $MyInvocation.ScriptName) -Option Constant -Scope Script
    Set-Variable PROGRAM_FILES_86 $(if ($OS_ARCH -eq '64-bit') { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles }) -Option Constant -Scope Script

    New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
    Set-Variable WordRegPath (Get-ItemProperty 'HKCR:\Word.Application\CurVer' -ErrorAction SilentlyContinue) -Option Constant
    Set-Variable OfficeVersion $(if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' }) -Option Constant -Scope Script
    Set-Variable OfficeC2RClientExe "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe" -Option Constant -Scope Script
    Set-Variable OfficeInstallType $(if ($OfficeVersion) { if (Test-Path $OfficeC2RClientExe) { 'C2R' } else { 'MSI' } }) -Option Constant -Scope Script

    Set-Variable CCleanerExe "$env:ProgramFiles\CCleaner\CCleaner$(if ($OS_ARCH -eq '64-bit') {'64'}).exe" -Option Constant -Scope Script
    Set-Variable DefragglerExe "$env:ProgramFiles\Defraggler\df$(if ($OS_ARCH -eq '64-bit') {'64'}).exe" -Option Constant -Scope Script
    Set-Variable DefenderExe "$env:ProgramFiles\Windows Defender\MpCmdRun.exe" -Option Constant -Scope Script
    Set-Variable GoogleUpdateExe "$PROGRAM_FILES_86\Google\Update\GoogleUpdate.exe" -Option Constant -Scope Script

    Set-Variable LogicalDisk (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID = 'C:'") -Option Constant
    Set-Variable SystemPartition ($LogicalDisk | Select-Object @{L = 'FreeSpace'; E = { '{0:N2}' -f ($_.FreeSpace / 1GB) } }, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } }) -Option Constant -Scope Script

    Out-Success
}


function Out-SystemInfo {
    $BTN_UpdateOffice.Enabled = $BTN_OfficeInsider.Enabled = $OfficeInstallType -eq 'C2R'
    $BTN_RunCCleaner.Enabled = Test-Path $CCleanerExe
    $BTN_RunDefraggler.Enabled = Test-Path $DefragglerExe
    $BTN_GoogleUpdate.Enabled = Test-Path $GoogleUpdateExe

    Add-Log $INF 'Current system information:'
    Add-Log $INF '  Hardware'

    Set-Variable ComputerSystem (Get-WmiObject Win32_ComputerSystem) -Option Constant
    Set-Variable Computer ($ComputerSystem | Select-Object Manufacturer, Model, SystemSKUNumber, PCSystemType, @{L = 'RAM'; E = { '{0:N2}' -f ($_.TotalPhysicalMemory / 1GB) } }) -Option Constant
    if ($Computer) {
        Add-Log $INF "    Computer type:  $(Switch ($Computer.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
        Add-Log $INF "    Computer model:  $($Computer.Manufacturer) $($Computer.Model) $(if ($Computer.SystemSKUNumber) {"($($Computer.SystemSKUNumber))"})"
        Add-Log $INF "    RAM available:  $($Computer.RAM) GB"
    }

    Set-Variable Processors (Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors) -Option Constant
    if ($Processors) {
        ForEach ($Item In $Processors) {
            Add-Log $INF "    CPU name:  $($Item.Name)"
            Add-Log $INF "    Cores / Threads:  $($Item.NumberOfCores) / $($Item.NumberOfLogicalProcessors)"
        }
    }

    Set-Variable VideoControllers ((Get-WmiObject Win32_VideoController).Name) -Option Constant
    if ($VideoControllers) { ForEach ($Item In $VideoControllers) { Add-Log $INF "    GPU name:  $Item" } }

    if ($OS_VERSION -gt 7) {
        Set-Variable Storage (Get-PhysicalDisk | Select-Object BusType, FriendlyName, HealthStatus, MediaType, FirmwareVersion, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } }) -Option Constant
        if ($Storage) {
            ForEach ($Item In $Storage) {
                $Details = "$($Item.BusType)$(if ($Item.MediaType -ne 'Unspecified') {' ' + $Item.MediaType}), $($Item.Size) GB, $($Item.HealthStatus), Firmware: $($Item.FirmwareVersion)"
                Add-Log $INF "    Storage:  $($Item.FriendlyName) ($Details)"
            }
        }
    }
    else {
        Set-Variable Storage (Get-WmiObject Win32_DiskDrive | Select-Object Model, Status, FirmwareRevision, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } }) -Option Constant
        if ($Storage) { ForEach ($Item In $Storage) { Add-Log $INF "    Storage:  $($Item.Model) ($($Item.Size) GB, Health: $($Item.Status), Firmware: $($Item.FirmwareRevision))" } }
    }

    if ($SystemPartition) {
        Add-Log $INF "    Free space on system partition: $($SystemPartition.FreeSpace) GB / $($SystemPartition.Size) GB ($((Get-FreeDiskSpace).ToString('P')))"
    }

    Set-Variable OfficeYear $(Switch ($OfficeVersion) { 16 { '2016 / 2019' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } }) -Option Constant
    Set-Variable OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' }) -Option Constant
    Set-Variable Win10Release ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId) -Option Constant

    Add-Log $INF '  Software'
    Add-Log $INF "    BIOS version:  $((Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion)"
    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $OS_ARCH"
    Add-Log $INF "    $(if ($OS_VERSION -eq 10) {'OS release / '})Build number:  $(if ($OS_VERSION -eq 10) {"v$Win10Release / "})$OS_BUILD"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OfficeInstallType) {`"($OfficeInstallType installation type)`"})"
    Add-Log $INF "    PowerShell version:  $PS_VERSION.$($PSVersionTable.PSVersion.Minor)"
}
