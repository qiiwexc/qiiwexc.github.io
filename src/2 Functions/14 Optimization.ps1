function CloudFlareDNS {
    Write-Log $INF 'Changing DNS address to CloudFlare DNS (1.1.1.1 / 1.0.0.1)...'

    $CurrentNetworkAdapter = (Get-NetAdapter -Physical | Where-Object Status -eq 'Up').ifIndex

    if (-not $CurrentNetworkAdapter) {
        Write-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Write-Log $ERR 'This could mean that computer is not connected'
        return
    }

    try {
        $Message = 'Changing DNS address to CloudFlare DNS...'
        $Command = "Set-DnsClientServerAddress -InterfaceIndex $CurrentNetworkAdapter -ServerAddresses ('1.1.1.1', '1.0.0.1')"
        Start-Process 'powershell' "-Command `"Write-Host $Message; $Command`"" -Verb RunAs -Wait
    }
    catch [Exception] {
        Write-Log $ERR "Failed to change DNS address: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'CloudFlare DNS was set up successfully'
}


function RunCCleaner {
    if (-not $CCleanerWarningShown) {
        Write-Log $WRN 'This task runs silent cleanup with CCleaner using current CCleaner settings'
        Write-Log $WRN 'Click the button again to contunue'
        $script:CCleanerWarningShown = $True
        return
    }

    Write-Log $INF 'Starting CCleaner background task...'

    try {Start-Process $CCleanerExe '/auto'}
    catch [Exception] {
        Write-Log $ERR "Cleanup failed: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'CCleaner is running'
}


function DeleteRestorePoints {
    Write-Log $INF 'Deleting all restore points'

    try {Start-Process 'vssadmin' 'delete shadows /all' -Verb RunAs -Wait}
    catch [Exception] {
        Write-Log $ERR "Failed to delete all restore points: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'All restore points deleted successfully'
}


function OptimizeDrive {
    Write-Log $INF 'Starting drive optimization...'

    try {Start-Process 'defrag' '/C /H /U /O' -Verb RunAs}
    catch [Exception] {
        Write-Log $ERR "Failed to optimize the drive: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Drive optimization is running'
}
