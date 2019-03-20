function CheckForUpdates {
    $VersionURL = 'https://qiiwexc.github.io/d/version'
    Write-Log $_INF 'Checking for updates...'

    try {$LatestVersion = (Invoke-WebRequest -Uri $VersionURL).ToString() -Replace "`n", ''}
    catch [Exception] {
        Write-Log $_ERR "Failed to check for update: $($_.Exception.Message)"
        return
    }

    $UpdateAvailable = [DateTime]::ParseExact($LatestVersion, 'yy.M.d', $null) -gt [DateTime]::ParseExact($_VERSION, 'yy.M.d', $null)

    if ($UpdateAvailable) {
        Write-Log $_WRN "Newer version available: v$LatestVersion"
        DownloadUpdate
    }
    else {Write-Log $_INF 'Currently running the latest version'}
}


function DownloadUpdate {
    $DownloadURL = 'https://qiiwexc.github.io/d/qiiwexc.ps1'
    $TargetFile = $MyInvocation.ScriptName

    Write-Log $_WRN 'Downloading new version...'

    try {Invoke-WebRequest -Uri $DownloadURL -OutFile $TargetFile}
    catch [Exception] {
        Write-Log $_ERR "Failed to download update: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Restarting...'

    try {Start-Process -FilePath 'powershell' -ArgumentList $TargetFile}
    catch [Exception] {
        Write-Log $_ERR "Failed to start new version: $($_.Exception.Message)"
        return
    }

    ExitScript
}
