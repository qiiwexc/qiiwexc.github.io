Function Set-CloudFlareDNS {
    Add-Log $WRN 'Internet connection may get interrupted briefly'
    Add-Log $INF 'Changing DNS server to CloudFlare DNS (1.1.1.1 / 1.0.0.1)...'

    if (-not (Get-NetworkAdapter)) {
        Add-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Add-Log $ERR 'This could mean that computer is not connected'
        Return
    }

    try { Start-ExternalProcess -Elevated -Hidden "(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True').SetDNSServerSearchOrder(`$('1.1.1.1', '1.0.0.1'))" }
    catch [Exception] { Add-Log $ERR "Failed to change DNS server: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-DriveOptimization {
    Add-Log $INF "Starting $(if ($OS_VERSION -le 7) { '(C:) ' })drive optimization..."

    Set-Variable -Option Constant Command "Start-Process -NoNewWindow 'defrag' $(if ($OS_VERSION -gt 7) { "'/C /H /U /O'" } else { "'C: /H /U'" })"
    try { Start-ExternalProcess -Elevated -Title:'Optimizing drives...' $Command }
    catch [Exception] { Add-Log $ERR "Failed to optimize drives: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-Defraggler {
    Add-Log $INF 'Starting (C:) drive optimization with Defraggler...'

    try { Start-ExternalProcess -Elevated -Title:'Optimizing drives...' "Start-Process -NoNewWindow $DefragglerExe 'C:'" }
    catch [Exception] { Add-Log $ERR "Failed start Defraggler: $($_.Exception.Message)"; Return }

    Out-Success
}
