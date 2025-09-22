Function Get-CurrentVersion {
    if ($PS_VERSION -le 2) {
        Write-Log $WRN "Automatic self-update requires PowerShell 3 or higher (currently running on PowerShell $PS_VERSION)"
        Return
    }

    Write-Log $INF 'Checking for updates...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) {
        Write-Log $ERR "Failed to check for updates: $IsNotConnected"
        Return
    }

    $ProgressPreference = 'SilentlyContinue'
    try {
        Set-Variable -Option Constant LatestVersion ([Version](Invoke-WebRequest '{URL_VERSION_FILE}').ToString())
        $ProgressPreference = 'Continue'
    } catch [Exception] {
        $ProgressPreference = 'Continue'
        Write-ExceptionLog $_ 'Failed to check for updates'
        Return
    }

    if ($LatestVersion -gt $VERSION) {
        Write-Log $WRN "Newer version available: v$LatestVersion"
        Get-Update
    } else {
        Out-Status 'No updates available'
    }
}


Function Get-Update {
    Set-Variable -Option Constant TargetFileBat "$PATH_CURRENT_DIR\qiiwexc.bat"

    Write-Log $WRN 'Downloading new version...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)

    if ($IsNotConnected) {
        Write-Log $ERR "Failed to download update: $IsNotConnected"
        Return
    }

    try {
        Invoke-WebRequest '{URL_BAT_FILE}' -OutFile $TargetFileBat
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to download update'
        Return
    }

    Out-Success
    Write-Log $WRN 'Restarting...'

    try {
        Start-Script $TargetFileBat
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to start new version'
        Return
    }

    Exit-Script
}
