function Get-CurrentVersion {
    Write-LogInfo 'Checking for updates...'

    Set-Variable -Option Constant IsNotConnected (Test-NetworkConnection)
    if ($IsNotConnected) {
        Write-LogError "Failed to check for updates: $IsNotConnected"
        return
    }

    $ProgressPreference = 'SilentlyContinue'
    try {
        Set-Variable -Option Constant LatestVersion ([Version](Invoke-WebRequest '{URL_VERSION_FILE}').ToString())
        $ProgressPreference = 'Continue'
    } catch [Exception] {
        $ProgressPreference = 'Continue'
        Write-ExceptionLog $_ 'Failed to check for updates'
        return
    }

    if ($LatestVersion -gt $VERSION) {
        Write-LogWarning "Newer version available: v$LatestVersion"
        Update-Self
    } else {
        Out-Status 'No updates available'
    }
}


function Update-Self {
    Set-Variable -Option Constant TargetFileBat "$PATH_CURRENT_DIR\qiiwexc.bat"

    Write-LogWarning 'Downloading new version...'

    Set-Variable -Option Constant IsNotConnected (Test-NetworkConnection)

    if ($IsNotConnected) {
        Write-LogError "Failed to download update: $IsNotConnected"
        return
    }

    try {
        Invoke-WebRequest '{URL_BAT_FILE}' -OutFile $TargetFileBat
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to download update'
        return
    }

    Out-Success
    Write-LogWarning 'Restarting...'

    try {
        Invoke-CustomCommand $TargetFileBat
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to start new version'
        return
    }

    Exit-Script
}
