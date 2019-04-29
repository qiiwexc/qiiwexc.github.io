function Start-GoogleUpdate {
    Add-Log $INF 'Starting Google Update...'

    try { Start-Process $GoogleUpdateExe '/c' }
    catch [Exception] { Add-Log $ERR "Failed to update Google software: $($_.Exception.Message)"; Return }

    try { Start-Process $GoogleUpdateExe '/ua /installsource scheduler' }
    catch [Exception] { Add-Log $ERR "Failed to update Google software: $($_.Exception.Message)"; Return }

    Out-Success
}


function Start-StoreAppUpdate {
    Add-Log $INF 'Starting Microsoft Store apps update...'

    Set-Variable Command "(Get-WmiObject MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap').UpdateScanMethod()" -Option Constant
    try { Start-Process 'powershell' "-Command `"$Command`"" -Verb RunAs -Wait -WindowStyle Hidden }
    catch [Exception] { Add-Log $ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"; Return }

    Out-Success
}


function Set-OfficeInsiderChannel {
    Add-Log $INF 'Switching Microsoft Office to insider update channel...'

    try { Start-Process $OfficeC2RClientExe '/changesetting Channel="InsiderFast"' -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to switch Microsoft Office update channel: $($_.Exception.Message)"; Return }

    Out-Success
}


function Start-OfficeUpdate {
    Add-Log $INF 'Starting Microsoft Office update...'

    try { Start-Process $OfficeC2RClientExe '/update user' -Wait }
    catch [Exception] { Add-Log $ERR "Failed to update Microsoft Office: $($_.Exception.Message)"; Return }

    Out-Success
}


function Start-WindowsUpdate {
    Add-Log $INF 'Starting Windows Update...'

    try { if ($OS_VERSION -gt 7) { Start-Process 'UsoClient' 'StartInteractiveScan' -Wait } else { Start-Process 'wuauclt' '/detectnow /updatenow' -Wait } }
    catch [Exception] { Add-Log $ERR "Failed to update Windows: $($_.Exception.Message)"; Return }

    Out-Success
}
