function Update-App {
    Set-Variable -Option Constant AppBatFile ([String]"$PATH_WORKING_DIR\qiiwexc.bat")

    Set-Variable -Option Constant IsUpdateAvailable ([Bool](Get-UpdateAvailability))

    if ($IsUpdateAvailable) {
        Get-NewVersion $AppBatFile

        Write-LogWarning 'Restarting...'

        try {
            Invoke-CustomCommand $AppBatFile
        } catch [Exception] {
            Write-LogException $_ 'Failed to start new version'
            return
        }

        Exit-App -Update
    }
}


function Get-UpdateAvailability {
    Write-LogInfo 'Checking for updates...'

    if ($DevMode) {
        Out-Status 'Skipping in dev mode'
        return
    }

    Set-Variable -Option Constant NoConnection ([String](Test-NetworkConnection))
    if ($NoConnection) {
        Write-LogError "Failed to check for updates: $NoConnection"
        return
    }

    try {
        Set-Variable -Option Constant VersionFile ([String]"$PATH_APP_DIR\version")
        Set-Variable -Option Constant LatestVersion ([String](Invoke-WebRequest -Uri '{URL_VERSION_FILE}'))
        Set-Variable -Option Constant AvailableVersion ([Version]$LatestVersion)
    } catch [Exception] {
        Write-LogException $_ 'Failed to check for updates'
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
        [String][Parameter(Position = 0, Mandatory)]$AppBatFile
    )

    Write-LogWarning 'Downloading new version...'

    Set-Variable -Option Constant NoConnection ([String](Test-NetworkConnection))

    if ($NoConnection) {
        Write-LogError "Failed to download update: $NoConnection"
        return
    }

    try {
        Invoke-WebRequest -Uri '{URL_BAT_FILE}' -OutFile $AppBatFile
    } catch [Exception] {
        Write-LogException $_ 'Failed to download update'
        return
    }

    Out-Success
}
