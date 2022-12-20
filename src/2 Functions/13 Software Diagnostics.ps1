Function Start-DiskCleanup {
    Add-Log $INF 'Starting disk cleanup utility...'

    try { Start-Process -Verb RunAs 'cleanmgr' '/lowdisk' }
    catch [Exception] { Add-Log $ERR "Failed to start disk cleanup utility: $($_.Exception.Message)"; Return }

    Out-Success
}

Function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    Set-Variable -Option Constant ScanHealth "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /ScanHealth'"
    Set-Variable -Option Constant RestoreHealth $(if ($OS_VERSION -gt 7) { "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /RestoreHealth'" } else { '' })
    Set-Variable -Option Constant SFC "Start-Process -NoNewWindow 'sfc' '/scannow'"

    try { Start-ExternalProcess -Elevated -Title:'Checking Windows health...' @($ScanHealth, $RestoreHealth, $SFC) }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}
