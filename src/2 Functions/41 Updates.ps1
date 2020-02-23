Function Start-StoreAppUpdate {
    Add-Log $INF 'Starting Microsoft Store apps update...'

    Set-Variable -Option Constant Command "(Get-WmiObject MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap').UpdateScanMethod()"
    try { Start-Process -Verb RunAs -Wait -WindowStyle Hidden 'PowerShell' "-Command `"$Command`"" }
    catch [Exception] { Add-Log $ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-OfficeUpdate {
    Add-Log $INF 'Starting Microsoft Office update...'

    try {
        Start-Process $OfficeC2RClientExe '/changesetting Channel="InsiderFast"' -Verb RunAs
        Start-Process $OfficeC2RClientExe '/update user' -Wait
    }
    catch [Exception] { Add-Log $ERR "Failed to update Microsoft Office: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-WindowsUpdate {
    Add-Log $INF 'Starting Windows Update...'

    try { if ($OS_VERSION -gt 7) { Start-Process -Wait 'UsoClient' 'StartInteractiveScan' } else { Start-Process -Wait 'wuauclt' '/detectnow /updatenow' } }
    catch [Exception] { Add-Log $ERR "Failed to update Windows: $($_.Exception.Message)"; Return }

    Out-Success
}
