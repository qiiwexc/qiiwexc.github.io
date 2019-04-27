function Get-CurrentVersion {
    if ($PS_VERSION -le 2) {
        Add-Log $WRN "Automatic self-update is not supported on PowerShell $PS_VERSION (PowerShell 3 and higher required)."
        Return
    }

    Add-Log $INF 'Checking for updates...'

    $IsNotConnected = Get-ConnectionStatus
    if ($IsNotConnected) {
        Add-Log $ERR "Failed to check for updates: $IsNotConnected"
        Return
    }

    try {
        $LatestVersion = (Invoke-WebRequest 'https://qiiwexc.github.io/d/version').ToString().Replace("`r", '').Replace("`n", '')
        $UpdateAvailable = [DateTime]::ParseExact($LatestVersion, 'yy.M.d', $null) -gt [DateTime]::ParseExact($VERSION, 'yy.M.d', $null)
    }
    catch [Exception] {
        Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"
        Return
    }

    if ($UpdateAvailable) {
        Add-Log $WRN "Newer version available: v$LatestVersion"
        Get-Update
    }
    else { Write-Log ' No updates available' }
}


function Get-Update {
    $DownloadURL = 'https://qiiwexc.github.io/d/qiiwexc.ps1'
    $TargetFile = $MyInvocation.ScriptName

    Add-Log $WRN 'Downloading new version...'

    $IsNotConnected = Get-ConnectionStatus
    if ($IsNotConnected) {
        Add-Log $ERR "Failed to download update: $IsNotConnected"
        Return
    }

    try { Invoke-WebRequest $DownloadURL -OutFile $TargetFile }
    catch [Exception] {
        Add-Log $ERR "Failed to download update: $($_.Exception.Message)"
        Return
    }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try { Start-Process 'powershell' $TargetFile }
    catch [Exception] {
        Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"
        Return
    }

    Exit-Script
}
