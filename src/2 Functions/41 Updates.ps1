function Start-GoogleUpdate {
    Add-Log $INF 'Starting Google Update...'

    try {Start-Process $GoogleUpdateExe '/c'}
    catch [Exception] {
        Add-Log $ERR "Failed to update Google software: $($_.Exception.Message)"
        return
    }

    try {Start-Process $GoogleUpdateExe '/ua /installsource scheduler'}
    catch [Exception] {
        Add-Log $ERR "Failed to update Google software: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-StoreAppUpdate {
    Add-Log $INF 'Starting Microsoft Store apps update...'

    try {
        $Message = 'Updating Microsoft Store apps...'
        $Command = "(Get-WmiObject -Namespace 'root\cimv2\mdm\dmmap' -Class 'MDM_EnterpriseModernAppManagement_AppManagement01').UpdateScanMethod()"
        Start-Process 'powershell' "-Command `"Write-Host $Message; $Command`"" -Verb RunAs
    }
    catch [Exception] {
        Add-Log $ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Set-OfficeInsiderChannel {
    Add-Log $INF 'Switching Microsoft Office to insider update channel...'

    try {Start-Process $OfficeC2RClientExe '/changesetting Channel="InsiderFast"' -Verb RunAs -Wait}
    catch [Exception] {
        Add-Log $ERR "Failed to switch Microsoft Office update channel: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-OfficeUpdate {
    Add-Log $INF 'Starting Microsoft Office update...'

    try {Start-Process $OfficeC2RClientExe '/update user' -Wait}
    catch [Exception] {
        Add-Log $ERR "Failed to update Microsoft Office: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-WindowsUpdate {
    Add-Log $INF 'Starting Windows Update...'

    try {Start-Process 'UsoClient' 'StartInteractiveScan' -Wait}
    catch [Exception] {
        Add-Log $ERR "Failed to update Windows: $($_.Exception.Message)"
        return
    }

    Out-Success
}
