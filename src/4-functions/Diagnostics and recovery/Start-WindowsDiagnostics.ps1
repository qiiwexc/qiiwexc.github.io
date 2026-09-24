function Invoke-SystemRepairTool {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Name,
        [Parameter(Position = 1, Mandatory)][String]$FilePath,
        [Parameter(Position = 2, Mandatory)][String[]]$Arguments,
        [Parameter(Position = 3, Mandatory)][Int]$ProgressFrom,
        [Parameter(Position = 4, Mandatory)][Double]$ProgressShare
    )

    Write-ActivityProgress $ProgressFrom "Running $Name..."
    try {
        $Null = & $FilePath @Arguments 2>&1 | ForEach-Object {
            if ("$_" -match '(\d+\.?\d*)%') {
                Write-ActivityProgress ([Int]($ProgressFrom + [Double]$Matches[1] * $ProgressShare))
            }
        }

        # Output alone does not tell a failed run apart, as these tools print progress up to the end either way
        if ($LASTEXITCODE -ne 0) {
            throw "exit code $LASTEXITCODE"
        }

        Out-Success
    } catch {
        Out-Failure "$Name failed: $_"
    }
}

function Start-WindowsDiagnostics {
    New-Activity 'Running Windows diagnostics'

    Set-Variable -Option Constant LogPath ([String]"$PATH_APP_DIR\windows_diagnostics.log")

    Initialize-AppDirectory

    Invoke-SystemRepairTool 'DISM CheckHealth' 'DISM' @('/Online', '/Cleanup-Image', '/CheckHealth') 5 0.1
    Invoke-SystemRepairTool 'DISM ScanHealth' 'DISM' @('/Online', '/Cleanup-Image', '/ScanHealth') 15 0.2
    Invoke-SystemRepairTool 'DISM RestoreHealth' 'DISM' @('/Online', '/Cleanup-Image', '/RestoreHealth') 35 0.25
    Invoke-SystemRepairTool 'SFC scannow' 'sfc' @('/scannow') 60 0.3

    Write-ActivityProgress 90 'Parsing SFC logs...'
    [Collections.Generic.List[String]]$LogLines = @()
    $LogLines.Add('=== SFC Scan Results ===')
    $LogLines.Add("Date: $(Get-Date)")
    $LogLines.Add('')
    try {
        Set-Variable -Option Constant CbsLogPath ([String]"$env:SystemRoot\Logs\CBS\CBS.log")
        if (Test-Path $CbsLogPath) {
            # CBS.log can exceed 100 MB — read in chunks instead of loading it whole.
            # @($_) keeps array semantics for -match, which filters instead of returning a Bool
            Set-Variable -Option Constant SfcEntries ([String[]](Get-Content $CbsLogPath -ReadCount 1000 -ErrorAction Stop | ForEach-Object { @($_) -match '\[SR\]' }))
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
