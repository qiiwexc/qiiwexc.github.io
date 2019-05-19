Function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    Set-Variable SetTitle "(Get-Host).UI.RawUI.WindowTitle = 'Checking Windows health...'" -Option Constant

    try { Start-Process 'PowerShell' "-Command `"$SetTitle; Start-Process 'DISM' '/Online /Cleanup-Image /ScanHealth' -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-Windows {
    Add-Log $INF 'Starting Windows repair...'

    Set-Variable SetTitle "(Get-Host).UI.RawUI.WindowTitle = 'Repairing Windows...'" -Option Constant

    try { Start-Process 'PowerShell' "-Command `"$SetTitle; Start-Process 'DISM' '/Online /Cleanup-Image /RestoreHealth' -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to repair Windows: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-SystemFiles {
    Add-Log $INF 'Starting system file integrity check...'

    try { Start-Process 'PowerShell' "-Command (Get-Host).UI.RawUI.WindowTitle = 'Checking system files...'; Start-Process 'sfc' '/scannow' -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to check system file integrity: $($_.Exception.Message)"; Return }

    Out-Success
}
