function Get-CurrentVersion {
    $VersionURL = 'https://qiiwexc.github.io/d/version'
    Add-Log $INF 'Checking for updates...'

    $IsNotConnected = Get-ConnectionStatus
    if ($IsNotConnected) {
        Add-Log $ERR "Failed to check for updates: $IsNotConnected"
        return
    }

    try {$LatestVersion = (Invoke-WebRequest $VersionURL).ToString() -Replace "`n", ''}
    catch [Exception] {
        Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"
        return
    }

    $UpdateAvailable = [DateTime]::ParseExact($LatestVersion, 'yy.M.d', $null) -gt [DateTime]::ParseExact($VERSION, 'yy.M.d', $null)

    if ($UpdateAvailable) {
        Add-Log $WRN "Newer version available: v$LatestVersion"
        Get-Update
    }
    else {Write-Log ' No updates available'}
}


function Get-Update {
    $DownloadURL = 'https://qiiwexc.github.io/d/qiiwexc.ps1'
    $TargetFile = $MyInvocation.ScriptName

    Add-Log $WRN 'Downloading new version...'

    $IsNotConnected = Get-ConnectionStatus
    if ($IsNotConnected) {
        Add-Log $ERR "Failed to download update: $IsNotConnected"
        return
    }

    try {Invoke-WebRequest $DownloadURL -OutFile $TargetFile}
    catch [Exception] {
        Add-Log $ERR "Failed to download update: $($_.Exception.Message)"
        return
    }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try {Start-Process 'powershell' $TargetFile}
    catch [Exception] {
        Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"
        return
    }

    Exit-Script
}
