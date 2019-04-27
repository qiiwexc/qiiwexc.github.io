function Get-SystemInfo {
    Add-Log $INF 'Gathering system information...'

    $OperatingSystem = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version

    $script:OS_NAME = $OperatingSystem.Caption
    $script:OS_BUILD = $OperatingSystem.Version
    $script:OS_ARCH = if ($OperatingSystem.OSArchitecture -like '64-*') { '64-bit' } else { '32-bit' }
    $script:OS_VERSION = if ($OS_BUILD -Match '10.0.*') { 10 } elseif ($OS_BUILD -Match '6.3.*') { 8.1 } elseif ($OS_BUILD -Match '6.2.*') { 8 } elseif ($OS_BUILD -Match '6.1.*') { 7 } else { 'Vista or older' }

    New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
    $WordRegPath = Get-ItemProperty 'HKCR:\Word.Application\CurVer' -ErrorAction SilentlyContinue
    $script:OfficeVersion = if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' }
    $script:OfficeC2RClientExe = "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
    $script:OfficeInstallType = if ($OfficeVersion) { if (Test-Path $OfficeC2RClientExe) { 'C2R' } else { 'MSI' } }

    $LogicalDisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID = 'C:'"
    $script:SystemPartition = $LogicalDisk | Select-Object @{L = 'FreeSpaceGB'; E = { '{0:N2}' -f ($_.FreeSpace / 1GB) } }, @{L = 'SizeGB'; E = { '{0:N2}' -f ($_.Size / 1GB) } }

    Out-Success
}


function Out-SystemInfo {
    Add-Log $INF 'Current system information:'
    Add-Log $INF '  Hardware'

    $Computer = Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, SystemSKUNumber, PCSystemType, @{L = 'RAM'; E = { '{0:N2}' -f ($_.TotalPhysicalMemory / 1GB) } }
    if ($Computer) {
        Add-Log $INF "    Computer type:  $(switch ($Computer.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
        Add-Log $INF "    Computer model:  $($Computer.Manufacturer) $($Computer.Model) $(if ($Computer.SystemSKUNumber) {"($($Computer.SystemSKUNumber))"})"
        Add-Log $INF "    RAM available:  $($Computer.RAM) GB"
    }

    $Processors = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors
    if ($Processors) {
        foreach ($Item in $Processors) {
            Add-Log $INF "    CPU name:  $($Item.Name)"
            Add-Log $INF "    Cores / Threads:  $($Item.NumberOfCores) / $($Item.NumberOfLogicalProcessors)"
        }
    }

    $VideoControllers = (Get-WmiObject Win32_VideoController).Name
    if ($VideoControllers) { foreach ($Item in $VideoControllers) { Add-Log $INF "    GPU name:  $Item" } }

    if ($OS_VERSION -gt 7) {
        $Storage = Get-PhysicalDisk | Select-Object BusType, FriendlyName, HealthStatus, MediaType, @{L = 'Firmware'; E = { $_.FirmwareVersion } }, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } }
        if ($Storage) {
            foreach ($Item in $Storage) {
                Add-Log $INF "    Storage:  $($Item.FriendlyName) ($($Item.BusType) $($Item.MediaType), $($Item.Size) GB, $($Item.HealthStatus), Firmware: $($Item.Firmware))"
            }
        }
    }
    else {
        $Storage = Get-WmiObject Win32_DiskDrive | Select-Object Model, Status, @{L = 'Firmware'; E = { $_.FirmwareRevision } }, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } }
        if ($Storage) { foreach ($Item in $Storage) { Add-Log $INF "    Storage:  $($Item.Model) ($($Item.Size) GB, Health: $($Item.Status), Firmware: $($Item.Firmware))" } }
    }

    if ($SystemPartition) {
        Add-Log $INF "    Free space on system partition: $($SystemPartition.FreeSpaceGB) GB / $($SystemPartition.SizeGB) GB ($((Get-FreeDiskSpace).ToString('P')))"
    }

    $OfficeYear = switch ($OfficeVersion) { 16 { '2016 / 2019' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } }
    $OfficeName = if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' }
    $Win10Release = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId

    Add-Log $INF '  Software'
    Add-Log $INF "    BIOS version:  $((Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion)"
    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $OS_ARCH"
    Add-Log $INF "    $(if ($OS_VERSION -eq 10) {'OS release / '})Build number:  $(if ($OS_VERSION -eq 10) {"v$Win10Release / "})$OS_BUILD"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OfficeInstallType) {`"($OfficeInstallType installation type)`"})"
    Add-Log $INF "    PowerShell version:  $PS_VERSION.$($PSVersionTable.PSVersion.Minor)"
}
