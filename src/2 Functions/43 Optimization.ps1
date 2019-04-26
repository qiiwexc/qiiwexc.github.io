function Set-CloudFlareDNS {
    Add-Log $WRN 'Internet connection may get interrupted briefly'
    Add-Log $INF 'Changing DNS server to CloudFlare DNS (1.1.1.1 / 1.0.0.1)...'

    if (-not (Get-NetworkAdapter)) {
        Add-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Add-Log $ERR 'This could mean that computer is not connected'
        return
    }

    $Command = "(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True').SetDNSServerSearchOrder(`$('1.1.1.1', '1.0.0.1'))"
    try { Start-Process 'powershell' "-Command `"Write-Host 'Changing DNS server to CloudFlare DNS...'; $Command`"" -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to change DNS server: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-DriveOptimization {
    Add-Log $INF 'Starting drive optimization...'

    try { Start-Process 'defrag' $(if ($OS_VERSION -gt 7) { '/C /H /U /O' } else { 'C: /H /U' }) -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to optimize drives: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-Defraggler {
    Add-Log $INF 'Starting (C:) drive optimization with Defraggler...'

    try { Start-Process $DefragglerExe 'C:\' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed start Defraggler: $($_.Exception.Message)"
        return
    }

    Out-Success
}
