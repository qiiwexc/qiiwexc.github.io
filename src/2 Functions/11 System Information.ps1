$_SYSTEM_INFO = New-Object System.Object

function GatherSystemInformation {
    Write-Log $_INF 'Gathering system information...'

    $ComputerSystem = Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, PCSystemType, @{L = 'RAM'; E = {[Math]::Round($_.TotalPhysicalMemory, 2) / 1GB}}
    $Processor = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, ThreadCount
    $VideoController = Get-WmiObject Win32_VideoController | Select-Object CurrentHorizontalResolution, CurrentVerticalResolution, CurrentRefreshRate, Name
    $SystemLogicalDisk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = '3'"
    $SystemPartition = $SystemLogicalDisk | Select-Object -Property @{L = 'FreeSpaceGB'; E = {'{0:N2}' -f ($_.FreeSpace / 1GB)}}, @{L = 'SizeGB'; E = {'{0:N2}' -f ($_.Size / 1GB)}}
    $OperatingSystem = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version

    $SystemType = switch ($ComputerSystem.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} }
    $SystemManufacturer = $ComputerSystem.Manufacturer
    $SystemModel = $ComputerSystem.Model
    $BIOSVersion = (Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion
    $ProcessorName = $Processor.Name
    $NumberOfCores = $Processor.NumberOfCores
    $NumberOfThreads = $Processor.ThreadCount
    $RAMSize = $ComputerSystem.RAM
    $GPUName = $VideoController.Name
    $HorizontalResolution = $VideoController.CurrentHorizontalResolution
    $VerticalResolution = $VideoController.CurrentVerticalResolution
    $RefreshRate = $VideoController.CurrentRefreshRate
    $DriveModel = ($SystemLogicalDisk.GetRelated('Win32_DiskPartition').GetRelated('Win32_DiskDrive')).Model
    $SystemPartitionSize = $SystemPartition.SizeGB
    $SystemPartitionFreeSpace = $SystemPartition.FreeSpaceGB
    $OSName = $OperatingSystem.Caption
    $OSArchitecture = $OperatingSystem.OSArchitecture
    $OSRelease = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId
    $OSVersion = $OperatingSystem.Version

    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'Type' -Value "$SystemType" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'Manufacturer' -Value "$SystemManufacturer" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'Model' -Value "$SystemModel" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'BIOSVersion' -Value "$BIOSVersion" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'CPU' -Value "$ProcessorName" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'NumberOfCores' -Value "$NumberOfCores" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'NumberOfThreads' -Value "$NumberOfThreads" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'RAM' -Value "$RAMSize" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'GPU' -Value "$GPUName"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'HorizontalResolution' -Value "$HorizontalResolution"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'VerticalResolution' -Value "$VerticalResolution"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'RefreshRate' -Value "$RefreshRate"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'DriveModel' -Value "$DriveModel"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'SystemPartitionSize' -Value "$SystemPartitionSize"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'SystemPartitionFreeSpace' -Value "$SystemPartitionFreeSpace"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'OperatingSystem' -Value "$OSName"
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'Architecture' -Value "$OSArchitecture"
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'OSVersion' -Value "$OSVersion"
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'OSRelease' -Value "$OSRelease"

    $_LOG.AppendText(' Done')
}

function PrintSystemInformation {
    Write-Log $_INF 'Current system information:'
    Write-Log $_INF "   Computer model: $($_SYSTEM_INFO.Manufacturer), $($_SYSTEM_INFO.Model)"
    Write-Log $_INF "   BIOS version: $($_SYSTEM_INFO.BIOSVersion)"
    Write-Log $_INF "   CPU name: $($_SYSTEM_INFO.CPU)"
    Write-Log $_INF "   Cores / Threads: $($_SYSTEM_INFO.NumberOfCores) / $($_SYSTEM_INFO.NumberOfThreads)"
    Write-Log $_INF "   RAM size: $($_SYSTEM_INFO.RAM) GB"
    Write-Log $_INF "   GPU name: $($_SYSTEM_INFO.GPU)"
    Write-Log $_INF "   Main screen resolution: $($_SYSTEM_INFO.HorizontalResolution)x$($_SYSTEM_INFO.VerticalResolution) @$($_SYSTEM_INFO.RefreshRate)GHz"
    Write-Log $_INF "   System drive model: $($_SYSTEM_INFO.DriveModel)"
    Write-Log $_INF "   System partition - free / total: $($_SYSTEM_INFO.SystemPartitionFreeSpace) GB / $($_SYSTEM_INFO.SystemPartitionSize) GB"
    Write-Log $_INF "   Operation system: $($_SYSTEM_INFO.OperatingSystem)"
    Write-Log $_INF "   OS architecture: $($_SYSTEM_INFO.Architecture)"
    Write-Log $_INF "   OS version / build number: v$($_SYSTEM_INFO.OSRelease) / $($_SYSTEM_INFO.OSVersion)"
}
