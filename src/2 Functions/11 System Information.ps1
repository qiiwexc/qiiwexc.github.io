function Get-SystemInfo {
    Add-Log $INF 'Gathering system information...'

    $OperatingSystem = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version

    $script:OS_NAME = $OperatingSystem.Caption
    $script:OS_BUILD = $OperatingSystem.Version
    $script:OS_ARCH = if ($OperatingSystem.OSArchitecture -like '64-*') { '64-bit' } else { '32-bit' }
    $script:OS_VERSION = if ($OS_BUILD -match '10.0.*') { 10 } elseif ($OS_BUILD -match '6.3.*') { 8.1 } elseif ($OS_BUILD -match '6.2.*') { 8 } elseif ($OS_BUILD -match '6.1.*') { 7 } else { 'Vista or less' }
    $script:PS_VERSION = $PSVersionTable.PSVersion.Major

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
    $ComputerSystem = Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, SystemSKUNumber, PCSystemType, @{L = 'RAM'; E = { '{0:N2}' -f ($_.TotalPhysicalMemory / 1GB) } }
    $Processor = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors

    Add-Log $INF 'Current system information:'
    Add-Log $INF '  Hardware'
    Add-Log $INF "    Computer type:  $(switch ($ComputerSystem.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
    Add-Log $INF "    Computer model:  $($ComputerSystem.Manufacturer) $($ComputerSystem.Model) $(if ($ComputerSystem.SystemSKUNumber) {"($($ComputerSystem.SystemSKUNumber))"})"
    Add-Log $INF "    CPU name:  $($Processor.Name -Join '; ')"
    Add-Log $INF "    Cores / Threads:  $($Processor.NumberOfCores) / $($Processor.NumberOfLogicalProcessors)"
    Add-Log $INF "    RAM available:  $($ComputerSystem.RAM) GB"
    Add-Log $INF "    GPU name:  $((Get-WmiObject Win32_VideoController).Name -Join '; ')"

    if ($OS_VERSION -gt 7) {
        $Storage = Get-PhysicalDisk | Select-Object BusType, FirmwareVersion, FriendlyName, HealthStatus, MediaType, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } }
        Add-Log $INF "    Storage:  $($Storage.FriendlyName) ($($Storage.BusType) $($Storage.MediaType), $($Storage.Size) GB, $($Storage.HealthStatus), Firmware: $($Storage.FirmwareVersion))"
    }
    else {
        $Storage = Get-WmiObject Win32_DiskDrive | Select-Object FirmwareRevision, Model, Status, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } }
        Add-Log $INF "    Storage:  $($Storage.Model) ($($Storage.Size) GB, Health: $($Storage.Status), Firmware: $($Storage.FirmwareRevision))"
    }

    $OfficeYear = switch ($OfficeVersion) { 16 { '2016 / 2019' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } }
    $OfficeName = if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' }
    $Win10Release = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId

    Add-Log $INF "    Free space on system partition: $($SystemPartition.FreeSpaceGB) GB / $($SystemPartition.SizeGB) GB ($(($SystemPartition.FreeSpaceGB/$SystemPartition.SizeGB).tostring('P')))"
    Add-Log $INF '  Software'
    Add-Log $INF "    BIOS version:  $((Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion)"
    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $OS_ARCH"
    Add-Log $INF "    $(if ($OS_VERSION -eq 10) {'OS release / '})Build number:  $(if ($OS_VERSION -eq 10) {"v$Win10Release / "})$OS_BUILD"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OfficeInstallType) {`"($OfficeInstallType installation type)`"})"
    Add-Log $INF "    PowerShell version:  $PS_VERSION.$($PSVersionTable.PSVersion.Minor)"
}
