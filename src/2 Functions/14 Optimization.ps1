function CloudFlareDNS {
    Write-Log $_INF 'Changing DNS address to CloudFlare DNS (1.1.1.1 / 1.0.0.1)'

    $CurrentNetworkAdapter = (Get-NetAdapter -Physical | Where-Object Status -eq 'Up').ifIndex

    if (-not $CurrentNetworkAdapter) {
        Write-Log $_ERR 'Could not determine network adapter used to connect to the Internet'
        Write-Log $_ERR 'This could mean that computer is not connected'
        return
    }

    try {
        ExecuteAsAdmin "Set-DnsClientServerAddress -InterfaceIndex $CurrentNetworkAdapter -ServerAddresses ('1.1.1.1', '1.0.0.1')" `
            'Changing DNS address to CloudFlare DNS'
    }
    catch [Exception] {
        Write-Log $_ERR "Failed to change DNS address: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'CloudFlare DNS set up successfully'
}


function RunCCleaner {
    if (-not $CCleanerWarningShown) {
        Write-Log $_WRN 'This task runs silent cleanup with CCleaner using current CCleaner settings'
        Write-Log $_WRN 'Click the button again to contunue'
        $script:CCleanerWarningShown = $True
        return
    }

    Write-Log $_INF 'Cleanup started'

    try {Start-Process -Wait -FilePath $CCleanerExe -ArgumentList '/auto'}
    catch [Exception] {
        Write-Log $_ERR "Cleanup failed: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Cleanup completed successfully'
}


function OptimizeDrive {
    Write-Log $_INF 'Starting drive optimization'

    try {Start-Process -Verb RunAs -FilePath 'defrag' -ArgumentList '/C /H /U /O'}
    catch [Exception] {
        Write-Log $_ERR "Failed to optimize the drive: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Drive optimization completed'
}