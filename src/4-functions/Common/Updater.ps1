function Update-App {
    try {
        Set-Variable -Option Constant AppBatFile ([String]"$PATH_WORKING_DIR\qiiwexc.bat")

        Set-Variable -Option Constant IsUpdateAvailable ([Bool](Get-UpdateAvailability))

        if ($IsUpdateAvailable) {
            Get-NewVersion $AppBatFile

            Write-LogWarning 'Restarting...'

            Invoke-CustomCommand $AppBatFile

            Exit-App -Update
        }
    } catch {
        Out-Failure "Failed to start new version: $_"
    }
}


function Get-UpdateAvailability {
    try {
        Write-LogInfo 'Checking for updates...'

        if ($DevMode) {
            Out-Status 'Skipping in dev mode'
            return
        }

        Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
        if (-not $IsConnected) {
            return
        }

        Set-Variable -Option Constant AvailableVersion ([Version](Invoke-WebRequest -UseBasicParsing -Uri '{URL_VERSION_FILE}'))

        if ($AvailableVersion -gt $VERSION) {
            Write-LogWarning "Newer version available: v$AvailableVersion"
            return $True
        } else {
            Out-Status 'No updates available'
        }
    } catch {
        Out-Failure "Failed to check for updates: $_"
    }
}


function Get-NewVersion {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppBatFile
    )

    try {
        Write-LogWarning 'Downloading new version...'

        Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
        if (-not $IsConnected) {
            return
        }

        Invoke-WebRequest -Uri '{URL_BAT_FILE}' -OutFile $AppBatFile

        Out-Success
    } catch {
        Out-Failure "Failed to download update: $_"
    }
}
