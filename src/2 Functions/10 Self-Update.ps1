function CheckForUpdates ($ManualCheck) {
    $VersionURL = 'https://qiiwexc.github.io/version'
    Write-Log $_INF 'Checking for updates...'

    try {$LatestVersion = (Invoke-WebRequest -Uri $VersionURL).ToString()}
    catch [Exception] {Write-Log $_ERR "Failed to check for update: $($_.Exception.Message)"}

    $UpdateAvailable = (Get-Date $LatestVersion) -gt (Get-Date $_VERSION)

    if ($UpdateAvailable) {
        Write-Log $_WRN "Newer version available: v$LatestVersion"
        $ButtonCheckForUpdates.Visible = $False
        $ButtonDownloadUpdate.Visible = $True
        if (!$ManualCheck) {DownloadUpdate}
    }
    else {Write-Log $_INF 'Currently running the latest version'}
}

function DownloadUpdate {
    $DownloadURL = 'https://qiiwexc.github.io/qiiwexc.ps1'
    $TargetFile = $MyInvocation.ScriptName

    Write-Log $_WRN 'Downloading new version...'

    try {Invoke-WebRequest -Uri $DownloadURL -OutFile $TargetFile}
    catch [Exception] {Write-Log $_ERR "Failed to download update: $($_.Exception.Message)"}

    RestartAfterUpdate
}


function RestartAfterUpdate {
    Write-Log $_WRN 'Restarting...'

    try {Start-Process -FilePath 'powershell' -ArgumentList $TargetFile}
    catch [Exception] {Write-Log $_ERR "Failed to start new version: $($_.Exception.Message)"}

    $_FORM.Close()
}
