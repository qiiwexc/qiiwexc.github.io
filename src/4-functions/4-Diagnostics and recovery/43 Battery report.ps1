function Get-BatteryReport {
    Write-Log $INF 'Exporting battery report...'

    Set-Variable -Option Constant ReportPath "$PATH_APP_DIR\battery_report.html"

    powercfg /BatteryReport /Output $ReportPath

    Open-InBrowser $ReportPath

    Out-Success
}
