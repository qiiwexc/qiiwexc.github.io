function Update-App {
    Set-Variable -Option Constant AppBatFile ([String]"$PATH_WORKING_DIR\qiiwexc.bat")

    Set-Variable -Option Constant IsUpdateAvailable ([Bool](Get-UpdateAvailability))

    if ($IsUpdateAvailable) {
        Get-NewVersion $AppBatFile

        Write-LogWarning 'Restarting...'

        try {
            Invoke-CustomCommand $AppBatFile
        } catch {
            Out-Failure "Failed to start new version: $_"
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

    Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
    if (-not $IsConnected) {
        return
    }

    try {
        Set-Variable -Option Constant VersionFile ([String]"$PATH_APP_DIR\version")
        Set-Variable -Option Constant LatestVersion ([String](Invoke-WebRequest -UseBasicParsing -Uri '{URL_VERSION_FILE}'))
        Set-Variable -Option Constant AvailableVersion ([Version]$LatestVersion)
    } catch {
        Out-Failure "Failed to check for updates: $_"
        return
    }

    if ($AvailableVersion -gt $VERSION) {
        Write-LogWarning "Newer version available: v$AvailableVersion"
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

    Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
    if (-not $IsConnected) {
        return
    }

    try {
        Invoke-WebRequest -Uri '{URL_BAT_FILE}' -OutFile $AppBatFile
    } catch {
        Out-Failure "Failed to download update: $_"
        return
    }

    Out-Success
}
