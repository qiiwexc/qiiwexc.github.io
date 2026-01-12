function Update-MicrosoftStoreApps {
    Write-LogInfo 'Starting Microsoft Store apps update...'

    try {
        Invoke-CustomCommand -Elevated -HideWindow "Get-CimInstance MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap' | Invoke-CimMethod -MethodName 'UpdateScanMethod'"
        Out-Success
    } catch [Exception] {
        Write-LogException $_ 'Failed to update Microsoft Store apps'
    }
}
