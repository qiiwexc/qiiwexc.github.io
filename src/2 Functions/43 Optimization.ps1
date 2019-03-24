function Set-CloudFlareDNS {
    Add-Log $WRN 'Internet connection may get interrupted briefly'
    Add-Log $INF 'Changing DNS server to CloudFlare DNS (1.1.1.1 / 1.0.0.1)...'

    $CurrentNetworkAdapter = (Get-NetAdapter -Physical | Where-Object Status -eq 'Up').ifIndex

    if (-not $CurrentNetworkAdapter) {
        Add-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Add-Log $ERR 'This could mean that computer is not connected'
        return
    }

    try {
        $Message = 'Changing DNS server to CloudFlare DNS...'
        $Command = "Set-DnsClientServerAddress -InterfaceIndex $CurrentNetworkAdapter -ServerAddresses ('1.1.1.1', '1.0.0.1')"
        Start-Process 'powershell' "-Command `"Write-Host $Message; $Command`"" -Verb RunAs -Wait
    }
    catch [Exception] {
        Add-Log $ERR "Failed to change DNS server: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-DriveOptimization {
    Add-Log $INF 'Starting drive optimization...'

    try {Start-Process 'defrag' '/C /H /U /O' -Verb RunAs}
    catch [Exception] {
        Add-Log $ERR "Failed to optimize drives: $($_.Exception.Message)"
        return
    }

    Out-Success
}
