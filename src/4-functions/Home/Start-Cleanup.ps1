function Start-Cleanup {
    Write-LogInfo 'Cleaning up the system...'

    Write-LogInfo 'Clearing delivery optimization cache...'
    Delete-DeliveryOptimizationCache -Force
    Out-Success

    Write-LogInfo 'Clearing software distribution folder...'
    Set-Variable -Option Constant SoftwareDistributionPath "$env:SystemRoot\SoftwareDistribution\Download"
    Get-ChildItem -Path $SoftwareDistributionPath -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Ignore
    Out-Success

    Write-LogInfo 'Clearing Windows temp folder...'
    Set-Variable -Option Constant WindowsTemp "$env:SystemRoot\Temp"
    Get-ChildItem -Path $WindowsTemp -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Ignore
    Out-Success

    Write-LogInfo 'Clearing user temp folder...'
    Get-ChildItem -Path $PATH_TEMP_DIR -Recurse -Force -ErrorAction Ignore | Remove-Item -Recurse -Force -ErrorAction Ignore
    Out-Success

    Write-LogInfo 'Running system cleanup...'

    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | ForEach-Object -Process {
        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
    }

    Set-Variable -Option Constant VolumeCaches @(
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

    foreach ($VolumeCache in $VolumeCaches) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$VolumeCache" -Name StateFlags3224 -PropertyType DWord -Value 2 -Force
    }

    Start-Process 'cleanmgr.exe' -ArgumentList '/sagerun:3224' -Wait

    Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches | ForEach-Object -Process {
        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
    }

    Out-Success
}
