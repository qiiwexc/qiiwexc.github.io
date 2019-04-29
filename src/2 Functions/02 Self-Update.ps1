function Get-CurrentVersion {
    if ($PS_VERSION -le 2) { Add-Log $WRN "Automatic self-update requires PowerShell 3 or higher (currently running on PowerShell $PS_VERSION)"; Return }

    Add-Log $INF 'Checking for updates...'

    Set-Variable IsNotConnected (Get-ConnectionStatus) -Option Constant
    if ($IsNotConnected) { Add-Log $ERR "Failed to check for updates: $IsNotConnected"; Return }

    try {
        Set-Variable LatestVersion ((Invoke-WebRequest 'https://qiiwexc.github.io/d/version').ToString().Replace("`r", '').Replace("`n", '')) -Option Constant
        Set-Variable UpdateAvailable ([DateTime]::ParseExact($LatestVersion, 'yy.M.d', $Null) -gt [DateTime]::ParseExact($VERSION, 'yy.M.d', $Null)) -Option Constant
    }
    catch [Exception] { Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"; Return }

    if ($UpdateAvailable) {
        Add-Log $WRN "Newer version available: v$LatestVersion"
        Get-Update
    }
    else { Write-Log ' No updates available' }
}


function Get-Update {
    Set-Variable DownloadURL 'https://qiiwexc.github.io/d/qiiwexc.ps1' -Option Constant
    Set-Variable TargetFile $MyInvocation.ScriptName -Option Constant

    Add-Log $WRN 'Downloading new version...'

    Set-Variable IsNotConnected (Get-ConnectionStatus) -Option Constant
    if ($IsNotConnected) { Add-Log $ERR "Failed to download update: $IsNotConnected"; Return }

    try { Invoke-WebRequest $DownloadURL -OutFile $TargetFile }
    catch [Exception] { Add-Log $ERR "Failed to download update: $($_.Exception.Message)"; Return }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try { Start-Process 'powershell' $TargetFile }
    catch [Exception] { Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"; Return }

    Exit-Script
}
