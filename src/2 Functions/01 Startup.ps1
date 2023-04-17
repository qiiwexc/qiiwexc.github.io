Function Initialize-Startup {
    $FORM.Activate()
    Write-Log "[$((Get-Date).ToString())] Initializing..."

    if ($IS_ELEVATED) {
        Set-Variable -Option Constant IE_Registry_Key 'Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Main'
        if (!(Test-Path $IE_Registry_Key)) { New-Item $IE_Registry_Key -Force | Out-Null }
        Set-ItemProperty -Path $IE_Registry_Key -Name "DisableFirstRunCustomize" -Value 1
    }

    Set-Variable -Option Constant -Scope Script PATH_CURRENT_DIR $(Split-Path $MyInvocation.ScriptName)

    if ($PS_VERSION -lt 2) { Add-Log $WRN "PowerShell $PS_VERSION detected, while PowerShell 2 and newer are supported. Some features might not work correctly." }
    elseif ($PS_VERSION -eq 2) { Add-Log $WRN "PowerShell $PS_VERSION detected, some features are not supported and are disabled." }

    if ($OS_VERSION -lt 7) { Add-Log $WRN "Windows $OS_VERSION detected, while Windows 7 and newer are supported. Some features might not work correctly." }
    elseif ($OS_VERSION -lt 8) { Add-Log $WRN "Windows $OS_VERSION detected, some features are not supported and are disabled." }

    if ($PS_VERSION -gt 2) {
        try { [Net.ServicePointManager]::SecurityProtocol = 'Tls12' }
        catch [Exception] { Add-Log $WRN "Failed to configure security protocol, downloading from GitHub might not work: $($_.Exception.Message)" }

        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            Set-Variable -Option Constant -Scope Script ZIP_SUPPORTED $True
        }
        catch [Exception] {
            Add-Log $WRN "Failed to load 'System.IO.Compression.FileSystem' module: $($_.Exception.Message)"
        }
    }

    Add-Log $INF 'Current system information:'

    Set-Variable -Option Constant ComputerSystem (Get-WmiObject Win32_ComputerSystem)
    Set-Variable -Option Constant Computer ($ComputerSystem | Select-Object PCSystemType)
    if ($Computer) {
        Add-Log $INF "    Computer type:  $(Switch ($Computer.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
    }

    Set-Variable -Option Constant OfficeYear $(Switch ($OFFICE_VERSION) { 16 { '2016 / 2019 / 2021' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } })
    Set-Variable -Option Constant OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' })
    Set-Variable -Option Constant WindowsRelease ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId)

    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $(if ($OS_64_BIT) { '64-bit' } else { '32-bit' })"
    Add-Log $INF "    $(if ($OS_VERSION -eq 10) {'OS release / '})Build number:  $(if ($OS_VERSION -eq 10) {"v$WindowsRelease / "})$OS_BUILD"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OFFICE_INSTALL_TYPE) {`"($OFFICE_INSTALL_TYPE installation type)`"})"

    Get-CurrentVersion

    if ($OFFICE_INSTALL_TYPE -eq 'MSI' -and $OFFICE_VERSION -ge 15) {
        Add-Log $WRN 'MSI installation of Microsoft Office is detected.'
    }
}
