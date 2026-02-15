function Update-MicrosoftStoreApps {
    try {
        Write-LogInfo 'Starting Microsoft Store apps update...'

        if (Test-WindowsDebloatIsRunning) {
            Write-LogWarning 'Windows debloat utility is currently running, which may interfere with the Microsoft Store apps update process'
            Write-LogWarning 'Repeat the attempt after the debloat utility has finished running'
            return
        }

        Get-CimInstance MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap' | Invoke-CimMethod -MethodName 'UpdateScanMethod'

        Out-Success
    } catch {
        Out-Failure "Failed to update Microsoft Store apps: $_"
    }
}
