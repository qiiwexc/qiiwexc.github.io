Function Get-CurrentVersion {
    if ($PS_VERSION -le 2) {
        Add-Log $WRN "Automatic self-update requires PowerShell 3 or higher (currently running on PowerShell $PS_VERSION)"
        Return
    }

    Add-Log $INF 'Checking for updates...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) {
        Add-Log $ERR "Failed to check for updates: $IsNotConnected"
        Return
    }

    $ProgressPreference = 'SilentlyContinue'
    try {
        Set-Variable -Option Constant LatestVersion ([Version](Invoke-WebRequest $URL_VERSION_FILE).ToString())
        $ProgressPreference = 'Continue'
    } catch [Exception] {
        $ProgressPreference = 'Continue'
        Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"
        Return
    }

    if ($LatestVersion -gt $VERSION) {
        Add-Log $WRN "Newer version available: v$LatestVersion"
        Get-Update
    } else {
        Out-Status 'No updates available'
    }
}


Function Get-Update {
    Set-Variable -Option Constant TargetFilePs1 $MyInvocation.ScriptName

    Add-Log $WRN 'Downloading new version...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)

    if ($IsNotConnected) {
        Add-Log $ERR "Failed to download update: $IsNotConnected"
        Return
    }

    if ($CallerPath) {
        Set-Variable -Option Constant TargetFileBat "$CallerPath\qiiwexc.bat"

        try {
            Invoke-WebRequest $URL_BAT_FILE -OutFile $TargetFileBat
        } catch [Exception] {
            Add-Log $ERR "Failed to download update: $($_.Exception.Message)"
            Return
        }
    }

    try {
        Invoke-WebRequest $URL_PS1_FILE -OutFile $TargetFilePs1
    } catch [Exception] {
        Add-Log $ERR "Failed to download update: $($_.Exception.Message)"
        Return
    }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try {
        Start-ExternalProcess -BypassExecutionPolicy -HideConsole $TargetFilePs1
    } catch [Exception] {
        Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"
        Return
    }

    Exit-Script
}
