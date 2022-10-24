Function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    Set-Variable -Option Constant ScanHealth "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /ScanHealth'"
    Set-Variable -Option Constant RestoreHealth $(if ($OS_VERSION -gt 7) { "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /RestoreHealth'" } else { '' })
    Set-Variable -Option Constant SFC "Start-Process -NoNewWindow 'sfc' '/scannow'"

    try { Start-ExternalProcess -Elevated -Title:'Checking Windows health...' @($ScanHealth, $RestoreHealth, $SFC) }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-SecurityScans {
    Set-Variable -Option Constant SignatureUpdate $(if ($OS_VERSION -gt 7 -and (Test-Path $PATH_DEFENDER_EXE)) { "Start-Process -NoNewWindow -Wait '$PATH_DEFENDER_EXE' '-SignatureUpdate'" } else { '' })
    Set-Variable -Option Constant Scan $(if (Test-Path $PATH_DEFENDER_EXE) { "Start-Process -NoNewWindow -Wait '$PATH_DEFENDER_EXE' '-Scan -ScanType 2'" } else { '' })
    Set-Variable -Option Constant MRT "Start-Process -NoNewWindow -Wait 'mrt' '/q /f:y'"

    Add-Log $INF "Performing security scans..."
    try { Start-ExternalProcess -Elevated -Title:'Performing security scans...' @($SignatureUpdate, $Scan, $MRT) }
    catch [Exception] { Add-Log $ERR "Failed to perform security scans: $($_.Exception.Message)"; Return }

    Out-Success
}
