function Update-MicrosoftStoreApps {
    Write-LogInfo 'Starting Microsoft Store apps update...'

    try {
        Invoke-CustomCommand -Elevated -HideWindow "Get-CimInstance MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap' | Invoke-CimMethod -MethodName 'UpdateScanMethod'"
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to update Microsoft Store apps'
        return
    }

    Out-Success
}
