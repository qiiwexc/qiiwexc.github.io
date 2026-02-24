function Update-App {
    try {
        Set-Variable -Option Constant AppBatFile ([String]"$PATH_WORKING_DIR\qiiwexc.bat")

        Set-Variable -Option Constant IsUpdateAvailable ([Bool](Test-UpdateAvailability))

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


function Test-UpdateAvailability {
    try {
        Write-LogInfo 'Checking for updates...'

        if ($DevMode) {
            Out-Status 'Skipping in dev mode'
            return $False
        }

        if (-not (Test-NetworkConnection)) {
            return $False
        }

        Set-Variable -Option Constant Response ([PSObject](Invoke-WebRequest -UseBasicParsing -Uri '{URL_VERSION_FILE}' -Headers @{ 'User-Agent' = 'qiiwexc-updater' }))
        Set-Variable -Option Constant Release ([PSObject[]]($Response.Content | ConvertFrom-Json))
        Set-Variable -Option Constant AvailableVersion ([Version]$Release[0].tag_name.TrimStart('v'))

        if ($AvailableVersion -gt $VERSION) {
            Write-LogWarning "Newer version available: v$AvailableVersion"
            return $True
        } else {
            Out-Status 'No updates available'
            return $False
        }
    } catch {
        Out-Failure "Failed to check for updates: $_"
        return $False
    }
}


function Get-NewVersion {
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppBatFile
    )

    try {
        Write-LogWarning 'Downloading new version...'

        if (-not (Test-NetworkConnection)) {
            return
        }

        Invoke-WebRequest -UseBasicParsing -Uri '{URL_BAT_FILE_UPDATE}' -OutFile $AppBatFile

        Out-Success
    } catch {
        Out-Failure "Failed to download update: $_"
    }
}
