# Runs in an async operation — returns $True once the new version has been started,
# so the caller can close this instance on the UI thread
function Update-App {
    try {
        Set-Variable -Option Constant AppBatFile ([String]"$PATH_WORKING_DIR\qiiwexc.bat")

        if (-not (Test-UpdateAvailability)) {
            return $False
        }

        # Restarting without a verified download would start the old version again,
        # which would find the same update and restart in a loop
        if (-not (Get-NewVersion $AppBatFile)) {
            Write-LogWarning 'Continuing with the current version'
            return $False
        }

        Write-LogWarning 'Restarting...'

        Start-Process -FilePath $AppBatFile -ErrorAction Stop

        return $True
    } catch {
        Out-Failure "Failed to start new version: $_"
        return $False
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

        Set-Variable -Option Constant Response ([PSObject](Invoke-WebRequest -UseBasicParsing -Uri '{URL_VERSION_FILE}' -Headers @{ 'User-Agent' = 'qiiwexc-updater' } -TimeoutSec 15))
        Set-Variable -Option Constant Releases ([PSObject[]]($Response.Content | ConvertFrom-Json))

        # The update is downloaded from 'releases/latest', which never points to a pre-release or a draft —
        # comparing against one would report an update that the download cannot deliver
        Set-Variable -Option Constant Release ([PSObject]($Releases | Where-Object { -not $_.prerelease -and -not $_.draft } | Select-Object -First 1))
        if (-not $Release) {
            Out-Status 'No updates available'
            return $False
        }

        Set-Variable -Option Constant AvailableVersion ([Version]$Release.tag_name.TrimStart('v'))

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
            return $False
        }

        Initialize-AppDirectory

        Set-Variable -Option Constant DownloadedFile ([String]"$PATH_APP_DIR\qiiwexc.bat")
        Set-Variable -Option Constant ChecksumsFile ([String]"$PATH_APP_DIR\SHA256SUMS.txt")

        # Download to the temp directory first, so a failed or tampered download never replaces the working version
        Invoke-WebRequest -UseBasicParsing -Uri '{URL_BAT_FILE_UPDATE}' -OutFile $DownloadedFile -TimeoutSec 60 -ErrorAction Stop
        Invoke-WebRequest -UseBasicParsing -Uri '{URL_CHECKSUMS_FILE}' -OutFile $ChecksumsFile -TimeoutSec 15 -ErrorAction Stop

        Set-Variable -Option Constant Checksums ([String](Get-Content $ChecksumsFile -Raw -ErrorAction Stop))
        Set-Variable -Option Constant ChecksumMatch ([Text.RegularExpressions.Match]([Regex]::Match($Checksums, '(?m)^([0-9a-fA-F]{64})\s+\*?qiiwexc\.bat\s*$')))
        if (-not $ChecksumMatch.Success) {
            throw 'No checksum for qiiwexc.bat in the release checksums file'
        }

        Test-FileChecksum $DownloadedFile $ChecksumMatch.Groups[1].Value

        Move-Item -Force $DownloadedFile $AppBatFile -ErrorAction Stop

        Out-Success
        return $True
    } catch {
        Out-Failure "Failed to download update: $_"
        return $False
    }
}
