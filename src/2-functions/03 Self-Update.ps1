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
        Set-Variable -Option Constant LatestVersion ([Version](Invoke-WebRequest 'https://bit.ly/qiiwexc_version').ToString())
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
    Set-Variable -Option Constant DownloadUrlPs1 'https://bit.ly/qiiwexc_ps1'
    Set-Variable -Option Constant DownloadUrlBat 'https://qiiwexc.github.io/d/qiiwexc.bat'

    Set-Variable -Option Constant TargetFilePs1 $MyInvocation.ScriptName

    Add-Log $WRN 'Downloading new version...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)

    if ($IsNotConnected) {
        Add-Log $ERR "Failed to download update: $IsNotConnected"
        Return
    }

    if ($PATH_CALLER) {
        Set-Variable -Option Constant TargetFileBat $($PATH_CALLER + '\qiiwexc.bat')

        try {
            Invoke-WebRequest $DownloadUrlBat -OutFile $TargetFileBat
        } catch [Exception] {
            Add-Log $ERR "Failed to download update: $($_.Exception.Message)"
            Return
        }
    }

    try {
        Invoke-WebRequest $DownloadUrlPs1 -OutFile $TargetFilePs1
    } catch [Exception] {
        Add-Log $ERR "Failed to download update: $($_.Exception.Message)"
        Return
    }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try {
        Start-ExternalProcess -BypassExecutionPolicy "$TargetFilePs1 -HideConsole"
    } catch [Exception] {
        Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"
        Return
    }

    Exit-Script
}
