function Initialize-Startup {
    $FORM.Activate()
    $Timestamp = (Get-Date).ToString()
    Write-Log "[$Timestamp] Initializing..."

    if ($IS_ELEVATED) {
        $FORM.Text = "$($FORM.Text): Administrator"
        $BTN_Elevate.Text = 'Running as administrator'
        $BTN_Elevate.Enabled = $False
    }

    Get-SystemInformation
    if ($PS_VERSION -lt 5) {Add-Log $WRN "PowerShell $PS_VERSION detected, while versions >=5 are supported. Some features might not work correctly."}

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Get-CurrentVersion

    $BTN_GoogleUpdate.Enabled = Test-Path $GoogleUpdateExe
    $BTN_RunCCleaner.Enabled = Test-Path $CCleanerExe

    $BTN_UpdateOffice.Enabled = $OfficeInstallType -eq 'C2R'
    $BTN_OfficeInsider.Enabled = $BTN_UpdateOffice.Enabled

    $BTN_QuickSecurityScan.Enabled = Test-Path $DefenderExe
    $BTN_FullSecurityScan.Enabled = $BTN_QuickSecurityScan.Enabled

    Add-Type -AssemblyName System.IO.Compression.FileSystem
}


function Start-Elevated {
    if (-not $IS_ELEVATED) {
        try {Start-Process 'powershell' $MyInvocation.ScriptName -Verb RunAs}
        catch [Exception] {
            Add-Log $ERR "Failed to restart with administrator privileges: $($_.Exception.Message)"
            return
        }

        Exit-Script
    }
}
