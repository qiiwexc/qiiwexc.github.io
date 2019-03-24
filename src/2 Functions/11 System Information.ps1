function Get-SystemInfo {
    Add-Log $INF 'Gathering system information...'

    $OperatingSystem = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version

    $script:OS_NAME = $OperatingSystem.Caption
    $script:OS_ARCH = $OperatingSystem.OSArchitecture
    $script:OS_VERSION = $OperatingSystem.Version
    $script:PS_VERSION = $PSVersionTable.PSVersion.Major

    $script:CURRENT_DIR = Split-Path ($MyInvocation.ScriptName)

    $script:CCleanerExe = "$env:ProgramFiles\CCleaner\CCleaner$(if ($OS_ARCH -eq '64-bit') {'64'}).exe"
    $script:DefenderExe = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    $script:GoogleUpdateExe = "$(if ($OS_ARCH -eq '64-bit') {${env:ProgramFiles(x86)}} else {$env:ProgramFiles})\Google\Update\GoogleUpdate.exe"
    $script:OfficeC2RClientExe = "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"

    New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
    $WordRegPath = Get-ItemProperty 'HKCR:\Word.Application\CurVer' -ErrorAction SilentlyContinue
    $script:OfficeVersion = if ($WordRegPath) {($WordRegPath.'(default)') -Replace '\D+', ''}
    $script:OfficeInstallType = if ($OfficeVersion) {if (Test-Path $OfficeC2RClientExe) {'C2R'} else {'MSI'}}

    Out-Success
}


function Out-SystemInfo {
    $ComputerSystem = Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, PCSystemType, @{L = 'RAM'; E = {'{0:N2}' -f ($_.TotalPhysicalMemory / 1GB)}}
    $Processor = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, ThreadCount
    $LogicalDisk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType = '3'"
    $SystemPartition = $LogicalDisk | Select-Object @{L = 'FreeSpaceGB'; E = {'{0:N2}' -f ($_.FreeSpace / 1GB)}}, @{L = 'SizeGB'; E = {'{0:N2}' -f ($_.Size / 1GB)}}
    $OfficeYear = switch ($OfficeVersion) { 16 {'2016 / 2019'} 15 {'2013'} 14 {'2010'} 12 {'2007'} 11 {'2003'} }
    $OfficeName = if ($OfficeYear) {"Microsoft Office $OfficeYear"} else {'Unknown version or not installed'}

    Add-Log $INF 'Current system information:'
    Add-Log $INF '  Hardware'
    Add-Log $INF "    Computer type:  $(switch ($ComputerSystem.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
    Add-Log $INF "    Computer manufacturer:  $($ComputerSystem.Manufacturer)"
    Add-Log $INF "    Computer model:  $($ComputerSystem.Model)"
    Add-Log $INF "    CPU name:  $($Processor.Name)"
    Add-Log $INF "    Cores / Threads:  $($Processor.NumberOfCores) / $($Processor.ThreadCount)"
    Add-Log $INF "    RAM available:  $($ComputerSystem.RAM) GB"
    Add-Log $INF "    GPU name:  $((Get-WmiObject Win32_VideoController).Name)"
    Add-Log $INF "    System drive model:  $(($LogicalDisk.GetRelated('Win32_DiskPartition').GetRelated('Win32_DiskDrive')).Model)"
    Add-Log $INF "    System partition - free space: $($SystemPartition.FreeSpaceGB) GB / $($SystemPartition.SizeGB) GB ($(($SystemPartition.FreeSpaceGB/$SystemPartition.SizeGB).tostring('P')))"
    Add-Log $INF '  Software'
    Add-Log $INF "    BIOS version:  $((Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion)"
    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $OS_ARCH"
    Add-Log $INF "    OS version / build number:  v$((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId) / $OS_VERSION"
    Add-Log $INF "    PowerShell version:  $PS_VERSION"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OfficeInstallType) {`"($OfficeInstallType installation type)`"})"
}
