Function Initialize-Startup {
    $FORM.Activate()

    Add-LogMessage "[$((Get-Date).ToString())] Initializing..."

    Set-Variable -Option Constant IE_Registry_Key 'Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Main'

    New-Item $IE_Registry_Key -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $IE_Registry_Key -Name "DisableFirstRunCustomize" -Value 1 -ErrorAction SilentlyContinue

    if ($PS_VERSION -lt 2) {
        Write-Log $WRN "PowerShell $PS_VERSION detected, while PowerShell 2 and newer are supported. Some features might not work correctly."
    } elseif ($PS_VERSION -eq 2) {
        Write-Log $WRN "PowerShell $PS_VERSION detected, some features are not supported and are disabled."
    }

    if ($OS_VERSION -lt 8) {
        Write-Log $WRN "Windows $OS_VERSION detected, some features are not supported."
    }

    if ($PS_VERSION -gt 2) {
        try {
            [Net.ServicePointManager]::SecurityProtocol = 'Tls12'
        } catch [Exception] {
            Write-Log $WRN "Failed to configure security protocol, downloading from GitHub might not work: $($_.Exception.Message)"
        }

        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            Set-Variable -Option Constant -Scope Script ZIP_SUPPORTED $True
        } catch [Exception] {
            Set-Variable -Option Constant -Scope Script SHELL (New-Object -com Shell.Application)
            Write-Log $WRN "Failed to load 'System.IO.Compression.FileSystem' module: $($_.Exception.Message)"
        }
    }

    Write-Log $INF 'Current system information:'

    Set-Variable -Option Constant OfficeYear $(Switch ($OFFICE_VERSION) { 16 { '2016 / 2019 / 2021 / 2024' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } })
    Set-Variable -Option Constant OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' })
    Set-Variable -Option Constant WindowsRelease ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId)

    Write-Log $INF "    Operation system:  $($OPERATING_SYSTEM.Caption)"
    Write-Log $INF "    OS architecture:  $(if ($OS_64_BIT) { '64-bit' } else { '32-bit' })"
    Write-Log $INF "    OS language:  $SYSTEM_LANGUAGE"
    Write-Log $INF "    $(if ($OS_VERSION -ge 10) {'OS release / '})Build number:  $(if ($OS_VERSION -ge 10) {"v$WindowsRelease / "})$($OPERATING_SYSTEM.Version)"
    Write-Log $INF "    Office version:  $OfficeName $(if ($OFFICE_INSTALL_TYPE) {`"($OFFICE_INSTALL_TYPE installation type)`"})"

    Get-CurrentVersion
}
