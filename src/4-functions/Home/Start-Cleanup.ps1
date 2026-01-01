function Start-Cleanup {
    New-Activity 'Cleaning up the system...'

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Write-ActivityProgress -PercentComplete 10 -Task 'Clearing delivery optimization cache...'
    Delete-DeliveryOptimizationCache -Force
    Out-Success $LogIndentLevel

    Write-ActivityProgress -PercentComplete 20 -Task 'Clearing Windows temp folder...'
    Set-Variable -Option Constant WindowsTemp ([String]"$env:SystemRoot\Temp")
    Remove-Item -Path "$WindowsTemp\*" -Recurse -Force -ErrorAction Ignore
    Out-Success $LogIndentLevel

    Write-ActivityProgress -PercentComplete 30 -Task 'Clearing user temp folder...'
    Remove-Item -Path "$PATH_TEMP_DIR\*" -Recurse -Force -ErrorAction Ignore
    Out-Success $LogIndentLevel

    Write-ActivityProgress -PercentComplete 40 -Task 'Clearing software distribution folder...'
    Set-Variable -Option Constant SoftwareDistributionPath ([String]"$env:SystemRoot\SoftwareDistribution\Download")
    Remove-Item -Path "$SoftwareDistributionPath\*" -Recurse -Force -ErrorAction Ignore
    Out-Success $LogIndentLevel

    Write-ActivityProgress -PercentComplete 60 -Task 'Running system cleanup...'

    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | ForEach-Object -Process {
        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
    }
    Write-ActivityProgress -PercentComplete 70

    Set-Variable -Option Constant VolumeCaches (
        [Collections.Generic.List[String]]@(
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
            'Windows Error Reporting Files',
            'Windows ESD installation files',
            'Windows Defender',
            'Windows Upgrade Log Files'
        )
    )

    foreach ($VolumeCache in $VolumeCaches) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$VolumeCache" -Name StateFlags3224 -PropertyType DWord -Value 2 -Force
    }
    Write-ActivityProgress -PercentComplete 80

    Start-Process 'cleanmgr.exe' -ArgumentList '/sagerun:3224'

    Start-Sleep -Seconds 2

    Write-ActivityProgress -PercentComplete 90
    Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches | ForEach-Object -Process {
        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
    }

    Write-ActivityCompleted
}
