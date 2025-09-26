function Update-Windows {
    Write-Log $INF 'Starting Windows Update...'

    try {
        if ($OS_VERSION -gt 7) {
            Start-Process 'UsoClient' 'StartInteractiveScan'
        } else {
            Start-Process 'wuauclt' '/detectnow /updatenow'
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to update Windows'
        return
    }

    Out-Success
}


function Update-MicrosoftStoreApps {
    Write-Log $INF 'Starting Microsoft Store apps update...'

    try {
        Invoke-Command -Elevated -HideWindow "(Get-WmiObject MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap').UpdateScanMethod()"
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to update Microsoft Store apps'
        return
    }

    Out-Success
}


function Update-MicrosoftOffice {
    Write-Log $INF 'Starting Microsoft Office update...'

    try {
        Start-Process $PATH_OFFICE_C2R_CLIENT_EXE '/update user'
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to update Microsoft Office'
        return
    }

    Out-Success
}
