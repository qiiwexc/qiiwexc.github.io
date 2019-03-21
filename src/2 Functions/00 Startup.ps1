function Startup {
    $FORM.Activate()
    $LOG.AppendText("[$((Get-Date).ToString())] Initializing...")

    if ($IS_ELEVATED) {
        $FORM.Text = "$($FORM.Text): Administrator"
        $BTN_Elevate.Text = 'Running as admin'
        $BTN_Elevate.Enabled = $False
    }

    GatherSystemInformation
    if ($PS_VERSION -lt 5) {Write-Log $WRN "PowerShell $PS_VERSION detected, while versions >=5 are supported. Some features might not work."}

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    CheckForUpdates

    $BTN_GoogleUpdate.Enabled = Test-Path $GoogleUpdateExe
    $BTN_RunCCleaner.Enabled = Test-Path $CCleanerExe
    $BTN_QuickSecurityScan.Enabled = Test-Path $DefenderExe
    $BTN_FullSecurityScan.Enabled = $BTN_QuickSecurityScan.Enabled

    Add-Type -AssemblyName System.IO.Compression.FileSystem
}


function Elevate {
    if (-not $IS_ELEVATED) {
        Start-Process 'powershell' $MyInvocation.ScriptName -Verb RunAs
        ExitScript
    }
}
