function Start-Cleanup {
    if (Test-SdiIsRunning) {
        Write-LogWarning 'Snappy Driver Installer is currently running. Please close it before starting the cleanup process.'
        return
    }

    if ((Test-DownloadingWindowsUpdates) -or (Test-InstallingWindowsUpdates)) {
        Write-LogWarning 'Windows Update is currently running. Please wait for updates to complete before starting the cleanup process.'
        return
    }

    # Both run from the temp folders the cleanup empties: Win11Debloat from the user's, MAS from the system's
    if (Test-WindowsDebloatIsRunning) {
        Write-LogWarning 'Windows debloat utility is currently running. Please wait for it to finish before starting the cleanup process.'
        return
    }

    if (Test-ActivatorIsRunning) {
        Write-LogWarning 'MAS activator is currently running. Please wait for it to finish before starting the cleanup process.'
        return
    }

    New-Activity 'Cleaning up the system'

    Write-ActivityProgress 10 'Clearing delivery optimization cache...'
    Delete-DeliveryOptimizationCache -Force
    Out-Success

    Write-ActivityProgress 20 'Clearing Windows temp folder...'
    Set-Variable -Option Constant WindowsTemp ([String]"$env:SystemRoot\Temp")
    Remove-Item -Path "$WindowsTemp\*" -Recurse -Force -ErrorAction Ignore
    Out-Success

    Write-ActivityProgress 30 'Clearing user temp folder...'
    # Except the app's own folder, which holds what it downloaded, and from which the tools it started may still run
    Set-Variable -Option Constant AppDirName ([String](Split-Path -Leaf $PATH_APP_DIR))
    foreach ($Item in @(Get-ChildItem -LiteralPath $PATH_TEMP_DIR -Force -ErrorAction Ignore | Where-Object { $_.Name -ne $AppDirName })) {
        Remove-Item -LiteralPath $Item.FullName -Recurse -Force -ErrorAction Ignore
    }
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
            'Windows Defender',
            'Windows Error Reporting Files',
            'Windows ESD installation files',
            'Windows Upgrade Log Files'
        )
    )

    try {
        foreach ($VolumeCache in $VolumeCaches) {
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$VolumeCache" -Name StateFlags3224 -PropertyType DWord -Value 2 -Force
        }
        Write-ActivityProgress 80

        # Waited for: Disk Cleanup reads which of its handlers to run from the flags as it goes, so removing them
        # while it runs would cut it short, and on a slow machine it runs for minutes
        Start-Process 'cleanmgr.exe' "/d $env:SystemDrive /sagerun:3224" -Wait
    } finally {
        Write-ActivityProgress 90
        Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | ForEach-Object -Process {
            Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
        }
    }

    Out-Success

    Write-ActivityCompleted
}
