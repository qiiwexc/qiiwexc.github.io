function Update-App {
    Set-Variable -Option Constant AppBatFile "$PATH_CURRENT_DIR\qiiwexc.bat"

    Set-Variable -Option Constant IsUpdateAvailable (Get-UpdateAvailability)

    if ($IsUpdateAvailable) {
        Get-NewVersion $AppBatFile

        Write-LogWarning 'Restarting...'

        try {
            Invoke-CustomCommand $AppBatFile
        } catch [Exception] {
            Write-ExceptionLog $_ 'Failed to start new version'
            return
        }

        Exit-App
    }
}


function Get-UpdateAvailability {
    Write-LogInfo 'Checking for updates...'

    if ($DevMode) {
        Out-Status 'Skipping in dev mode'
        return
    }

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if ($NoConnection) {
        Write-LogError "Failed to check for updates: $NoConnection"
        return
    }

    try {
        Set-Variable -Option Constant VersionFile "$PATH_APP_DIR\version"
        Start-BitsTransfer -Source '{URL_VERSION_FILE}' -Destination $VersionFile -Dynamic
        Set-Variable -Option Constant LatestVersion ([Version](Get-Content $VersionFile -Raw))
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to check for updates'
        return
    }

    if ($LatestVersion -gt $VERSION) {
        Write-LogWarning "Newer version available: v$LatestVersion"
        return $True
    } else {
        Out-Status 'No updates available'
    }
}


function Get-NewVersion {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppBatFile
    )

    Write-LogWarning 'Downloading new version...'

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)

    if ($NoConnection) {
        Write-LogError "Failed to download update: $NoConnection"
        return
    }

    try {
        Start-BitsTransfer -Source '{URL_BAT_FILE}' -Destination $AppBatFile -Dynamic
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to download update'
        return
    }

    Out-Success
}
