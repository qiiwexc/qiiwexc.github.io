Function Initialize-Startup {
    $FORM.Activate()
    Write-Log "[$((Get-Date).ToString())] Initializing..."

    if ($IS_ELEVATED) {
        $FORM.Text = "$($FORM.Text): Administrator"
        $BTN_Elevate.Text = 'Running as administrator'
        $BTN_Elevate.Enabled = $False
    }

    Get-SystemInfo

    $CBOX_StartAAct.Checked = $CBOX_StartAAct.Enabled = $CBOX_StartKMSAuto.Checked = $CBOX_StartKMSAuto.Enabled = `
        $CBOX_StartOffice.Checked = $CBOX_StartOffice.Enabled = $CBOX_StartRufus.Checked = $CBOX_StartRufus.Enabled = `
        $CBOX_StartVictoria.Checked = $CBOX_StartVictoria.Enabled = $PS_VERSION -gt 2

    $BTN_RepairWindows.Enabled = $BTN_UpdateStoreApps.Enabled = $OS_VERSION -gt 7
    $BTN_StartSecurityScan.Enabled = Test-Path $DefenderExe

    Set-ButtonState

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

    Get-CurrentVersion

    if (-not (Test-Path "$PROGRAM_FILES_86\Unchecky\unchecky.exe")) {
        Add-Log $WRN 'Unchecky is not installed.'
        Add-Log $INF 'It is highly recommended to install Unchecky (see Downloads -> Essentials -> Unchecky).'
        Add-Log $INF "$TXT_UNCHECKY_INFO."
    }

    if ($OfficeInstallType -eq 'MSI' -and $OfficeVersion -ge 15) {
        Add-Log $WRN 'MSI installation of Microsoft Office is detected.'
        Add-Log $INF 'It is highly recommended to install Click-To-Run (C2R) version instead'
        Add-Log $INF '  (see Downloads -> Essentials -> Office 2013 - 2019).'
    }

    Set-Variable -Option Constant NetworkAdapter (Get-NetworkAdapter)
    if ($NetworkAdapter) {
        Set-Variable -Option Constant CurrentDnsServer $NetworkAdapter.DNSServerSearchOrder
        if (-not ($CurrentDnsServer -Match '1.1.1.*' -and $CurrentDnsServer -Match '1.0.0.*')) {
            Add-Log $WRN 'System is not configured to use CouldFlare DNS.'
            Add-Log $INF 'It is recommended to use CouldFlare DNS for faster domain name resolution and improved'
            Add-Log $INF '  privacy online (see Maintenance -> Optimization -> Setup CouldFlare DNS).'
        }
    }
}
