function Update-MicrosoftStoreApps {
    Write-LogInfo 'Starting Microsoft Store apps update...'

    try {
        Set-Variable -Option Constant Status (Get-CimInstance MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap' | Invoke-CimMethod -MethodName 'UpdateScanMethod').ReturnValue

        if ($Status -ne 0) {
            Write-LogError 'Failed to update Microsoft Store apps'
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to update Microsoft Store apps'
        return
    }

    Out-Success
}
