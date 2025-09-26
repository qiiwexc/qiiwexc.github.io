function Start-Cleanup {
    Write-Log $INF 'Cleaning up the system...'

    Write-Log $INF 'Clearing delivery optimization cache...'
    Delete-DeliveryOptimizationCache -Force
    Out-Success

    Write-Log $INF 'Clearing software distribution folder...'
    Set-Variable -Option Constant SoftwareDistributionPath "$env:SystemRoot\SoftwareDistribution\Download"
    Get-ChildItem -Path $SoftwareDistributionPath -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Ignore
    Out-Success

    Write-Log $INF 'Clearing Windows temp folder...'
    Set-Variable -Option Constant WindowsTemp "$env:SystemRoot\Temp"
    Get-ChildItem -Path $WindowsTemp -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Ignore
    Out-Success

    Write-Log $INF 'Clearing user temp folder...'
    Get-ChildItem -Path $PATH_TEMP_DIR -Recurse -Force -ErrorAction Ignore | Remove-Item -Recurse -Force -ErrorAction Ignore
    New-Item -Force -ItemType Directory $PATH_APP_DIR | Out-Null
    Out-Success

    Write-Log $INF 'Running system cleanup...'

    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | ForEach-Object -Process {
        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
    }

    Set-Variable -Option Constant VolumeCaches @(
        'Delivery Optimization Files',
        'Device Driver Packages',
        'Language Pack',
        'Previous Installations',
        'Setup Log Files',
        'System error memory dump files',
        'System error minidump files',
        'Temporary Setup Files',
        'Update Cleanup',
        'Windows Defender',
        'Windows ESD installation files',
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
