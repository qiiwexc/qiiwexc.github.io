function GatherSystemInformation {
    Write-Log $INF 'Gathering system information...'

    New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR

    $OperatingSystem = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version

    $script:_OS_NAME = $OperatingSystem.Caption
    $script:_OS_ARCH = $OperatingSystem.OSArchitecture
    $script:_OS_VER = $OperatingSystem.Version
    $script:PSVersion = $PSVersionTable.PSVersion.Major
    $script:OfficeVersion = (Get-ItemProperty 'HKCR:\Word.Application\CurVer').'(default)'

    $script:_CURRENT_DIR = (Split-Path ($MyInvocation.ScriptName))

    $script:GoogleUpdateExe = "$(if ($_SYSTEM_INFO.Architecture -eq '64-bit') {${env:ProgramFiles(x86)}} else {$env:ProgramFiles})\Google\Update\GoogleUpdate.exe"
    $script:CCleanerExe = "$env:ProgramFiles\CCleaner\CCleaner$(if ($_SYSTEM_INFO.Architecture -eq '64-bit') {'64'}).exe"
    $script:DefenderExe = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"


    $LOG.AppendText(' Done')
}


function PrintSystemInformation {
    $ComputerSystem = Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, PCSystemType, @{L = 'RAM'; E = {'{0:N2}' -f ($_.TotalPhysicalMemory / 1GB)}}
    $Processor = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, ThreadCount
    $SystemLogicalDisk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = '3'"
    $SystemPartition = $SystemLogicalDisk | Select-Object -Property @{L = 'FreeSpaceGB'; E = {'{0:N2}' -f ($_.FreeSpace / 1GB)}}, @{L = 'SizeGB'; E = {'{0:N2}' -f ($_.Size / 1GB)}}

    Write-Log $INF 'Current system information:'
    Write-Log $INF '  Hardware'
    Write-Log $INF "    Computer type:  $(switch ($ComputerSystem.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
    Write-Log $INF "    Computer manufacturer:  $($ComputerSystem.Manufacturer)"
    Write-Log $INF "    Computer model:  $($ComputerSystem.Model)"
    Write-Log $INF "    CPU name:  $($Processor.Name)"
    Write-Log $INF "    Cores / Threads:  $($Processor.NumberOfCores) / $($Processor.ThreadCount)"
    Write-Log $INF "    RAM available:  $($ComputerSystem.RAM) GB"
    Write-Log $INF "    GPU name:  $((Get-WmiObject Win32_VideoController).Name)"
    Write-Log $INF "    System drive model:  $(($SystemLogicalDisk.GetRelated('Win32_DiskPartition').GetRelated('Win32_DiskDrive')).Model)"
    Write-Log $INF "    System partition - free space: $($SystemPartition.FreeSpaceGB) GB / $($SystemPartition.SizeGB) GB ($(($SystemPartition.FreeSpaceGB/$SystemPartition.SizeGB).tostring('P')))"
    Write-Log $INF '  Software'
    Write-Log $INF "    BIOS version:  $((Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion)"
    Write-Log $INF "    Operation system:  $($OperatingSystem)"
    Write-Log $INF "    OS architecture:  $($Architecture)"
    Write-Log $INF "    OS version / build number:  v$((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId) / $($OSVersion)"
    Write-Log $INF "    PowerShell version:  $($PSVersion)"
    Write-Log $INF "    Office version:  $($OfficeVersion)"
}
