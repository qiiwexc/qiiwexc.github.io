function Start-Cleanup {
    if (Assert-SdiIsRunning) {
        Write-LogWarning 'Snappy Driver Installer is currently running. Please close it before starting the cleanup process.'
        return
    }

    if ((Assert-DownloadingWindowsUpdates) -or (Assert-InstallingWindowsUpdates)) {
        Write-LogWarning 'Windows Update is currently running. Please wait for updates to complete before starting the cleanup process.'
        return
    }

    New-Activity 'Cleaning up the system'
    Set-Icon ([IconName]::Cleanup)

    Write-ActivityProgress 10 'Clearing delivery optimization cache...'
    Delete-DeliveryOptimizationCache -Force
    Out-Success

    Write-ActivityProgress 20 'Clearing Windows temp folder...'
    Set-Variable -Option Constant WindowsTemp ([String]"$env:SystemRoot\Temp")
    Remove-Item -Path "$WindowsTemp\*" -Recurse -Force -ErrorAction Ignore
    Out-Success

    Write-ActivityProgress 30 'Clearing user temp folder...'
    Remove-Item -Path "$PATH_TEMP_DIR\*" -Recurse -Force -ErrorAction Ignore
    Out-Success

    Write-ActivityProgress 40 'Clearing software distribution folder...'
    Set-Variable -Option Constant SoftwareDistributionPath ([String]"$env:SystemRoot\SoftwareDistribution\Download")
    Remove-Item -Path "$SoftwareDistributionPath\*" -Recurse -Force -ErrorAction Ignore
    Out-Success

    Write-ActivityProgress 60 'Running system cleanup...'

    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | ForEach-Object -Process {
        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
    }
    Write-ActivityProgress 70

    Set-Variable -Option Constant VolumeCaches (
        [String[]]@(
            'Active Setup Temp Folders',
            'BranchCache',
            'D3D Shader Cache',
            'Delivery Optimization Files',
            'Device Driver Packages',
            'Diagnostic Data Viewer database files',
            'Downloaded Program Files',
            'Internet Cache Files',
            'Language Pack',
            'Old ChkDsk Files',
            'Previous Installations',
            'Recycle Bin',
            'RetailDemo Offline Content',
            'Setup Log Files',
            'System error memory dump files',
            'System error minidump files',
            'Temporary Files',
            'Temporary Setup Files',
            'Thumbnail Cache',
            'Update Cleanup',
            'User file versions',
            'Windows Defender',
            'Windows Error Reporting Files',
            'Windows ESD installation files',
            'Windows Upgrade Log Files'
        )
    )

    foreach ($VolumeCache in $VolumeCaches) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$VolumeCache" -Name StateFlags3224 -PropertyType DWord -Value 2 -Force
    }
    Write-ActivityProgress 80

    Start-Process 'cleanmgr.exe' '/d C: /sagerun:3224'

    Start-Sleep -Seconds 1

    Write-ActivityProgress 90
    Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | ForEach-Object -Process {
        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
    }

    Out-Success

    Write-ActivityCompleted
}
