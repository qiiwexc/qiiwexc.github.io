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

        if (-not (Test-NetworkConnection)) {
            return
        }

        Set-Variable -Option Constant Response ([PSObject](Invoke-WebRequest -UseBasicParsing -Uri '{URL_VERSION_FILE}'))
        Set-Variable -Option Constant Release ([PSObject[]]($Response.Content | ConvertFrom-Json))
        Set-Variable -Option Constant AvailableVersion ([Version]$Release[0].tag_name.TrimStart('v'))

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

        if (-not (Test-NetworkConnection)) {
            return
        }

        Invoke-WebRequest -Uri '{URL_BAT_FILE_UPDATE}' -OutFile $AppBatFile

        Out-Success
    } catch {
        Out-Failure "Failed to download update: $_"
    }
}
