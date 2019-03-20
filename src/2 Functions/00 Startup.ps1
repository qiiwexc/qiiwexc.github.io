function Startup {
    $_FORM.Activate()
    $_LOG.AppendText("[$((Get-Date).ToString())] Initializing...")

    if ($_IS_ELEVATED) {
        $_FORM.Text = "$($_FORM.Text): Administrator"
        $ButtonElevate.Text = 'Running as admin'
        $ButtonElevate.Enabled = $False
    }

    GatherSystemInformation
    CheckForUpdates

    if ($_SYSTEM_INFO.PSVersion -lt 5) {Write-Log $_WRN "PowerShell $_PS_VERSION detected, while versions >=5 are supported. Some features might not work."}

    $script:_CURRENT_DIR = (Split-Path ($MyInvocation.ScriptName))

    $script:GoogleUpdateExe = "$(if ($_SYSTEM_INFO.Architecture -eq '64-bit') {${env:ProgramFiles(x86)}} else {$env:ProgramFiles})\Google\Update\GoogleUpdate.exe"
    $ButtonGoogleUpdate.Enabled = Test-Path $GoogleUpdateExe

    $script:CCleanerExe = "$env:ProgramFiles\CCleaner\CCleaner$(if ($_SYSTEM_INFO.Architecture -eq '64-bit') {'64'}).exe"
    $ButtonRunCCleaner.Enabled = Test-Path $CCleanerExe

    $script:DefenderExe = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    $ButtonSecurityScanQuick.Enabled = Test-Path $DefenderExe
    $ButtonSecurityScanFull.Enabled = $ButtonSecurityScanQuick.Enabled
}


function Elevate {
    if (-not $_IS_ELEVATED) {
        Start-Process -Verb RunAs -FilePath 'powershell' -ArgumentList $MyInvocation.ScriptName
        ExitScript
    }
}
