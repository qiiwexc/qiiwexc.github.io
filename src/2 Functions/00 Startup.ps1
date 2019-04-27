function Initialize-Startup {
    $FORM.Activate()
    $Timestamp = (Get-Date).ToString()
    Write-Log "[$Timestamp] Initializing..."

    if ($IS_ELEVATED) {
        $FORM.Text = "$($FORM.Text): Administrator"
        $BTN_Elevate.Text = 'Running as administrator'
        $BTN_Elevate.Enabled = $False
    }

    Get-SystemInfo

    if ($PS_VERSION -lt 2) { Add-Log $WRN "PowerShell $PS_VERSION detected, while PowerShell 2 and newer are supported. Some features might not work correctly." }
    elseif ($PS_VERSION -eq 2) { Add-Log $WRN "PowerShell $PS_VERSION detected, some features are not supported and are disabled." }

    if ($OS_VERSION -lt 7) { Add-Log $WRN "Windows $OS_VERSION detected, while Windows 7 and newer are supported. Some features might not work correctly." }
    elseif ($OS_VERSION -lt 8) { Add-Log $WRN "Windows $OS_VERSION detected, some features are not supported and are disabled." }

    $script:CURRENT_DIR = Split-Path ($MyInvocation.ScriptName)
    $script:PROGRAM_FILES_86 = if ($OS_ARCH -eq '64-bit') { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles }

    $script:CCleanerExe = "$env:ProgramFiles\CCleaner\CCleaner$(if ($OS_ARCH -eq '64-bit') {'64'}).exe"
    $script:DefragglerExe = "$env:ProgramFiles\Defraggler\df$(if ($OS_ARCH -eq '64-bit') {'64'}).exe"
    $script:DefenderExe = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    $script:GoogleUpdateExe = "$PROGRAM_FILES_86\Google\Update\GoogleUpdate.exe"

    $CBOX_StartAAct.Enabled = $PS_VERSION -gt 2
    $CBOX_StartChewWGA.Enabled = $PS_VERSION -gt 2
    $CBOX_StartKMSAuto.Enabled = $PS_VERSION -gt 2
    $CBOX_StartOffice.Enabled = $PS_VERSION -gt 2
    $CBOX_StartRufus.Enabled = $PS_VERSION -gt 2
    $CBOX_StartVictoria.Enabled = $PS_VERSION -gt 2

    $BTN_WindowsCleanup.Enabled = $OS_VERSION -gt 7
    $BTN_RepairWindows.Enabled = $OS_VERSION -gt 7
    $BTN_UpdateStoreApps.Enabled = $OS_VERSION -gt 7

    $BTN_RunCCleaner.Enabled = Test-Path $CCleanerExe
    $BTN_RunDefraggler.Enabled = Test-Path $DefragglerExe
    $BTN_GoogleUpdate.Enabled = Test-Path $GoogleUpdateExe

    $BTN_UpdateOffice.Enabled = $OfficeInstallType -eq 'C2R'
    $BTN_OfficeInsider.Enabled = $BTN_UpdateOffice.Enabled

    $BTN_QuickSecurityScan.Enabled = Test-Path $DefenderExe
    $BTN_FullSecurityScan.Enabled = $BTN_QuickSecurityScan.Enabled

    if ($PS_VERSION -gt 2) {
        try { [Net.ServicePointManager]::SecurityProtocol = 'Tls12' }
        catch [Exception] { Add-Log $WRN "Failed to configure security protocol, downloading from GitHub might not work: $($_.Exception.Message)" }

        try { Add-Type -AssemblyName System.IO.Compression.FileSystem }
        catch [Exception] {
            Add-Log $WRN "Failed to load 'System.IO.Compression.FileSystem' module: $($_.Exception.Message)"
            $script:Shell = New-Object -com Shell.Application
        }
    }
    else { $script:Shell = New-Object -com Shell.Application }

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
        Add-Log $INF 'C2R versions of Office install updates silently in the background with no need to restart computer.'
    }

    if ($SystemPartition) {
        $FreeDiskSpace = Get-FreeDiskSpace
        if ($FreeDiskSpace -le 0.15) {
            Add-Log $WRN "System partition has only $($FreeDiskSpace.ToString('P')) of free space."
            Add-Log $INF 'It is recommended to clean up the disk (see Maintenance -> Cleanup).'
        }
    }

    $NetworkAdapter = Get-NetworkAdapter
    if ($NetworkAdapter) {
        $CurrentDnsServer = $NetworkAdapter.DNSServerSearchOrder
        if (-not ($CurrentDnsServer -Contains '1.1.1.1' -or $CurrentDnsServer -Contains '1.0.0.1')) {
            Add-Log $WRN 'System is not configured to use CouldFlare DNS.'
            Add-Log $INF 'It is recommended to use CouldFlare DNS for faster domain name resolution and improved'
            Add-Log $INF '  privacy online (see Maintenance -> Optimization -> Setup CouldFlare DNS).'
        }
    }
}
