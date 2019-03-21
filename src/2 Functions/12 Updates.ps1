function UpdateGoogleSoftware {
    Write-Log $INF 'Starting Google Update...'

    try {Start-Process $GoogleUpdateExe '/c'}
    catch [Exception] {
        Write-Log $ERR "Google Update failed: $($_.Exception.Message)"
        return
    }

    try {Start-Process $GoogleUpdateExe '/ua /installsource scheduler'}
    catch [Exception] {
        Write-Log $ERR "Google Update failed: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Google Update started successfully'
}


function UpdateStoreApps {
    Write-Log $INF 'Starting Microsoft Store apps update...'

    try {
        $Message = 'Updating Microsoft Store apps...'
        $Command = "(Get-WmiObject -Namespace 'root\cimv2\mdm\dmmap' -Class 'MDM_EnterpriseModernAppManagement_AppManagement01').UpdateScanMethod()"
        Start-Process 'powershell' "-Command `"Write-Host $Message; $Command`"" -Verb RunAs
    }
    catch [Exception] {
        Write-Log $ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Microsoft Store apps are updating'
}
