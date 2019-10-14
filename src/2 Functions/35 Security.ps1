Function Start-SecurityScan {
    if ($OS_VERSION -gt 7) {
        Add-Log $INF 'Updating security signatures...'

        [String]$SetTitle = "(Get-Host).UI.RawUI.WindowTitle = 'Updating security signatures...'"

        try { Start-Process 'PowerShell' "-Command `"$SetTitle; Start-Process '$DefenderExe' '-SignatureUpdate' -NoNewWindow`"" -Wait }
        catch [Exception] { Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"; Return }

        Out-Success
    }

    Add-Log $INF "Performing a security scan..."

    [String]$SetTitle = "(Get-Host).UI.RawUI.WindowTitle = 'Security scan is running...'"

    try { Start-Process 'PowerShell' "-Command `"$SetTitle; Start-Process '$DefenderExe' '-Scan -ScanType 2' -NoNewWindow`"" -Wait }
    catch [Exception] { Add-Log $ERR "Failed to perform a security scan: $($_.Exception.Message)"; Return }

    Out-Success
}
