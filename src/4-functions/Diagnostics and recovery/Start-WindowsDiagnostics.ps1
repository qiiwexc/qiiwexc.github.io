function Start-WindowsDiagnostics {
    New-Activity 'Running Windows diagnostics'

    Set-Variable -Option Constant LogPath ([String]"$PATH_APP_DIR\windows_diagnostics.log")

    Initialize-AppDirectory

    Write-ActivityProgress 5 'Running DISM CheckHealth...'
    try {
        $Null = & 'DISM' '/Online' '/Cleanup-Image' '/CheckHealth' 2>&1 |
        ForEach-Object {
            if ("$_" -match '(\d+\.?\d*)%') {
                Write-ActivityProgress ([Int](5 + [Double]$Matches[1] * 0.1))
            }
        }
        Out-Success
    } catch {
        Out-Failure "DISM CheckHealth failed: $_"
    }

    Write-ActivityProgress 15 'Running DISM ScanHealth...'
    try {
        $Null = & 'DISM' '/Online' '/Cleanup-Image' '/ScanHealth' 2>&1 |
        ForEach-Object {
            if ("$_" -match '(\d+\.?\d*)%') {
                Write-ActivityProgress ([Int](15 + [Double]$Matches[1] * 0.2))
            }
        }
        Out-Success
    } catch {
        Out-Failure "DISM ScanHealth failed: $_"
    }

    Write-ActivityProgress 35 'Running DISM RestoreHealth...'
    try {
        $Null = & 'DISM' '/Online' '/Cleanup-Image' '/RestoreHealth' 2>&1 |
        ForEach-Object {
            if ("$_" -match '(\d+\.?\d*)%') {
                Write-ActivityProgress ([Int](35 + [Double]$Matches[1] * 0.25))
            }
        }
        Out-Success
    } catch {
        Out-Failure "DISM RestoreHealth failed: $_"
    }

    Write-ActivityProgress 60 'Running SFC scannow...'
    try {
        $Null = & 'sfc' '/scannow' 2>&1 |
        ForEach-Object {
            if ("$_" -match '(\d+)%') {
                Write-ActivityProgress ([Int](60 + [Double]$Matches[1] * 0.3))
            }
        }
        Out-Success
    } catch {
        Out-Failure "SFC scannow failed: $_"
    }

    Write-ActivityProgress 90 'Parsing SFC logs...'
    [Collections.Generic.List[String]]$LogLines = @()
    $LogLines.Add('=== SFC Scan Results ===')
    $LogLines.Add("Date: $(Get-Date)")
    $LogLines.Add('')
    try {
        Set-Variable -Option Constant CbsLogPath ([String]"$env:SystemRoot\Logs\CBS\CBS.log")
        if (Test-Path $CbsLogPath) {
            Set-Variable -Option Constant CbsContent ([String[]](Get-Content $CbsLogPath -ErrorAction Stop))
            Set-Variable -Option Constant SfcEntries ([String[]]($CbsContent | Where-Object { $_ -match '\[SR\]' }))
            if ($SfcEntries.Count -gt 0) {
                $LogLines.Add("Found $($SfcEntries.Count) SFC log entry/entries:")
                foreach ($Entry in $SfcEntries) {
                    $LogLines.Add($Entry)
                }
            } else {
                $LogLines.Add('No SFC entries found in CBS.log.')
            }
        } else {
            $LogLines.Add('CBS.log not found.')
        }
    } catch {
        $LogLines.Add("Failed to parse SFC logs: $_")
    }

    Set-Content -Path $LogPath -Value ($LogLines -join "`r`n") -Encoding UTF8 -Force

    Write-ActivityProgress 95 'Opening log file...'
    Start-Process 'notepad.exe' $LogPath

    Write-ActivityCompleted
}
