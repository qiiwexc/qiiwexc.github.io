Function Get-WindowsUpdates {
    Write-Log $INF 'Starting Windows Update...'

    try {
        if ($OS_VERSION -gt 7) {
            Start-Process 'UsoClient' 'StartInteractiveScan'
        } else {
            Start-Process 'wuauclt' '/detectnow /updatenow'
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to update Windows'
        Return
    }

    Out-Success
}


Function Get-MicrosoftStoreUpdates {
    Write-Log $INF 'Starting Microsoft Store apps update...'

    try {
        Start-Script -Elevated -HideWindow "(Get-WmiObject MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap').UpdateScanMethod()"
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to update Microsoft Store apps'
        Return
    }

    Out-Success
}


Function Get-OfficeUpdates {
    Write-Log $INF 'Starting Microsoft Office update...'

    try {
        Start-Process $PATH_OFFICE_C2R_CLIENT_EXE '/update user'
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to update Microsoft Office'
        Return
    }

    Out-Success
}
