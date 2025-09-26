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
