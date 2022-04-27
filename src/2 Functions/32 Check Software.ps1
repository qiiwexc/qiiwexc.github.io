Function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    Set-Variable -Option Constant ComponentCleanup $(if ($OS_VERSION -gt 7) { "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /StartComponentCleanup'" })
    Set-Variable -Option Constant ScanHealth "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /ScanHealth'"
    Set-Variable -Option Constant RestoreHealth $(if ($OS_VERSION -gt 7) { "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /RestoreHealth'" })
    Set-Variable -Option Constant SFC "Start-Process -NoNewWindow 'sfc' '/scannow'"

    try { Start-ExternalProcess -Elevated -Title:'Checking Windows health...' @($ComponentCleanup, $ScanHealth, $RestoreHealth, $SFC) }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-SecurityScan {
    Set-Variable -Option Constant SignatureUpdate $(if ($OS_VERSION -gt 7 -and !(Test-Path $PATH_DEFENDER_EXE)) { "Start-Process -Wait '$PATH_DEFENDER_EXE' '-SignatureUpdate' -NoNewWindow" })
    Set-Variable -Option Constant Scan $(if (!(Test-Path $PATH_DEFENDER_EXE)) { "Start-Process -Wait '$PATH_DEFENDER_EXE' '-Scan -ScanType 2' -NoNewWindow" })
    Set-Variable -Option Constant MRT "Start-Process -Verb RunAs 'mrt' '/q /f:y'"

    Add-Log $INF "Performing a security scan..."
    try { Start-ExternalProcess -Title:'Performing a security scan...' @($SignatureUpdate, $Scan, $MRT) }
    catch [Exception] { Add-Log $ERR "Failed to perform a security scan: $($_.Exception.Message)"; Return }

    Out-Success
}
