function CheckForUpdates {
    $VersionURL = 'https://qiiwexc.github.io/d/version'
    Write-Log $INF 'Checking for updates...'

    try {$LatestVersion = (Invoke-WebRequest $VersionURL).ToString() -Replace "`n", ''}
    catch [Exception] {
        Write-Log $ERR "Failed to check for update: $($_.Exception.Message)"
        return
    }

    $UpdateAvailable = [DateTime]::ParseExact($LatestVersion, 'yy.M.d', $null) -gt [DateTime]::ParseExact($VERSION, 'yy.M.d', $null)

    if ($UpdateAvailable) {
        Write-Log $WRN "Newer version available: v$LatestVersion"
        DownloadUpdate
    }
    else {Write-Log $INF 'Currently running the latest version'}
}


function DownloadUpdate {
    $DownloadURL = 'https://qiiwexc.github.io/d/qiiwexc.ps1'
    $TargetFile = $MyInvocation.ScriptName

    Write-Log $WRN 'Downloading new version...'

    try {Invoke-WebRequest $DownloadURL -OutFile $TargetFile}
    catch [Exception] {
        Write-Log $ERR "Failed to download update: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Restarting...'

    try {Start-Process 'powershell' $TargetFile}
    catch [Exception] {
        Write-Log $ERR "Failed to start new version: $($_.Exception.Message)"
        return
    }

    ExitScript
}
