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
    if ($PS_VERSION -lt 5) {Add-Log $WRN "PowerShell $PS_VERSION detected, while versions >=5 are supported. Some features might not work correctly."}

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Get-CurrentVersion

    $script:CURRENT_DIR = Split-Path ($MyInvocation.ScriptName)

    $script:CCleanerExe = "$env:ProgramFiles\CCleaner\CCleaner$(if ($OS_ARCH -eq '64-bit') {'64'}).exe"
    $script:DefragglerExe = "$env:ProgramFiles\Defraggler\df$(if ($OS_ARCH -eq '64-bit') {'64'}).exe"
    $script:DefenderExe = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    $script:GoogleUpdateExe = "$(if ($OS_ARCH -eq '64-bit') {${env:ProgramFiles(x86)}} else {$env:ProgramFiles})\Google\Update\GoogleUpdate.exe"

    $BTN_RunCCleaner.Enabled = Test-Path $CCleanerExe
    $BTN_RunDefraggler.Enabled = Test-Path $DefragglerExe
    $BTN_GoogleUpdate.Enabled = Test-Path $GoogleUpdateExe

    $BTN_UpdateOffice.Enabled = $OfficeInstallType -eq 'C2R'
    $BTN_OfficeInsider.Enabled = $BTN_UpdateOffice.Enabled

    $BTN_QuickSecurityScan.Enabled = Test-Path $DefenderExe
    $BTN_FullSecurityScan.Enabled = $BTN_QuickSecurityScan.Enabled

    Add-Type -AssemblyName System.IO.Compression.FileSystem
}


function Exit-Script {$FORM.Close()}
