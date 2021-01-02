Function Start-StoreAppUpdate {
    Add-Log $INF 'Starting Microsoft Store apps update...'

    try { Start-ExternalProcess -Elevated -Hidden "(Get-WmiObject MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap').UpdateScanMethod()" }
    catch [Exception] { Add-Log $ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-OfficeUpdate {
    Add-Log $INF 'Starting Microsoft Office update...'

    try { Start-Process $OfficeC2RClientExe '/update user' }
    catch [Exception] { Add-Log $ERR "Failed to update Microsoft Office: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-WindowsUpdate {
    Add-Log $INF 'Starting Windows Update...'

    try { if ($OS_VERSION -gt 7) { Start-Process 'UsoClient' 'StartInteractiveScan' } else { Start-Process 'wuauclt' '/detectnow /updatenow' } }
    catch [Exception] { Add-Log $ERR "Failed to update Windows: $($_.Exception.Message)"; Return }

    Out-Success
}
