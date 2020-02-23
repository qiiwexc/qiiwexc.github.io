Function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    Set-Variable -Option Constant SetTitle "(Get-Host).UI.RawUI.WindowTitle = 'Checking Windows health...'"

    try { Start-Process -Verb RunAs 'PowerShell' "-Command `"$SetTitle; Start-Process 'DISM' '/Online /Cleanup-Image /ScanHealth' -NoNewWindow`"" }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-Windows {
    Add-Log $INF 'Starting Windows repair...'

    Set-Variable -Option Constant SetTitle "(Get-Host).UI.RawUI.WindowTitle = 'Repairing Windows...'"

    try { Start-Process -Verb RunAs 'PowerShell' "-Command `"$SetTitle; Start-Process 'DISM' '/Online /Cleanup-Image /RestoreHealth' -NoNewWindow`"" }
    catch [Exception] { Add-Log $ERR "Failed to repair Windows: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-SystemFiles {
    Add-Log $INF 'Starting system file integrity check...'

    try { Start-Process -Verb RunAs 'PowerShell' "-Command (Get-Host).UI.RawUI.WindowTitle = 'Checking system files...'; Start-Process 'sfc' '/scannow' -NoNewWindow`"" }
    catch [Exception] { Add-Log $ERR "Failed to check system file integrity: $($_.Exception.Message)"; Return }

    Out-Success
}
