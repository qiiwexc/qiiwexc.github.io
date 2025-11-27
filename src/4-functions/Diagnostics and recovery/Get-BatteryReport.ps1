function Get-BatteryReport {
    Write-LogInfo 'Exporting battery report...'

    Set-Variable -Option Constant ReportPath ([String]"$PATH_APP_DIR\battery_report.html")

    Initialize-AppDirectory

    powercfg /BatteryReport /Output $ReportPath

    Open-InBrowser $ReportPath

    Out-Success
}
