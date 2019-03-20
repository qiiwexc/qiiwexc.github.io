function UpdateGoogleSoftware {
    Write-Log $_INF 'Starting Google Update'

    try {Start-Process -Wait -FilePath $GoogleUpdateExe -ArgumentList '/c'}
    catch [Exception] {
        Write-Log $_ERR "Google Update failed: $($_.Exception.Message)"
        return
    }

    try {Start-Process -Wait -FilePath $GoogleUpdateExe -ArgumentList '/ua /installsource scheduler'}
    catch [Exception] {
        Write-Log $_ERR "Google Update failed: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Google software updated successfully'
}


function UpdateStoreApps {
    Write-Log $_INF 'Updating Microsoft Store apps'

    try {
        ExecuteAsAdmin "(Get-WmiObject -Namespace 'root\cimv2\mdm\dmmap' -Class 'MDM_EnterpriseModernAppManagement_AppManagement01').UpdateScanMethod()" `
            'Updating Microsoft Store apps...'
    }
    catch [Exception] {
        Write-Log $_ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Microsoft Store apps updated successfully'
}
