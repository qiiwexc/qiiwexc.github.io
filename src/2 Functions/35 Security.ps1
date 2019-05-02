function Start-SecurityScan {
    Param([Switch][Parameter(Position = 0)]$FullScan)

    if ($OS_VERSION -gt 7) {
        Add-Log $INF 'Updating security signatures...'

        [String]$SetTitle = "(Get-Host).UI.RawUI.WindowTitle = 'Updating security signatures...'"

        try { Start-Process 'powershell' "-Command `"$SetTitle; Start-Process '$DefenderExe' '-SignatureUpdate' -NoNewWindow`"" -Wait }
        catch [Exception] { Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"; Return }

        Out-Success
    }

    Set-Variable Mode $(if ($FullScan) { 'full' } else { 'quick' }) -Option Constant

    Add-Log $INF "Starting $Mode security scan..."

    [String]$SetTitle = "(Get-Host).UI.RawUI.WindowTitle = '$((Get-Culture).TextInfo.ToTitleCase($Mode)) security scan running...'"

    try { Start-Process 'powershell' "-Command `"$SetTitle; Start-Process '$DefenderExe' '-Scan -ScanType $(if ($FullScan) {2} else {1})' -NoNewWindow`"" -Wait }
    catch [Exception] { Add-Log $ERR "Failed to perform a $Mode security scan: $($_.Exception.Message)"; Return }

    Out-Success
}
