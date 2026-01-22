function Update-MicrosoftStoreApps {
    try {
        Write-LogInfo 'Starting Microsoft Store apps update...'

        Get-CimInstance MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap' | Invoke-CimMethod -MethodName 'UpdateScanMethod'

        Out-Success
    } catch {
        Out-Failure "Failed to update Microsoft Store apps: $_"
    }
}
