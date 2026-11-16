function Start-ChkDsk {
    param(
        [Switch]$ScheduleFullScan
    )

    try {
        if ($ScheduleFullScan) {
            Write-LogInfo 'Scheduling full Check Disk scan...'
            # chkdsk cannot check the drive Windows runs from, and asks whether to check it at the next restart instead,
            # in the display language, which the answer has to be in too
            Set-Variable -Option Constant YesKey ([String](Get-ChkDskYesKey))
            # Name the system drive explicitly — without it chkdsk targets the drive of the current directory
            Start-Process 'cmd' -ArgumentList "/c `"echo $YesKey| chkdsk %SystemDrive% /f /r`"" -NoNewWindow -Wait -ErrorAction Stop
            Write-LogWarning 'Full disc scan scheduled. Please restart your computer to allow Check Disk to run before Windows starts.'
            Out-Success
        } else {
            New-Activity 'Checking Disk'

            Initialize-AppDirectory
            Set-Variable -Option Constant LogPath ([String]"$PATH_APP_DIR\chkdsk.log")

            [Collections.Generic.List[String]]$LogLines = @()
            $PreviousEncoding = [Console]::OutputEncoding
            try {
                if ($OS_VERSION -ge 11) {
                    Set-Variable -Option Constant CodePage ([Int][System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ANSICodePage)
                } else {
                    Set-Variable -Option Constant CodePage ([Int][System.Globalization.CultureInfo]::CurrentCulture.TextInfo.OEMCodePage)
                }
                [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding($CodePage)
                # The system drive, named for the same reason as for the full scan above
                $Null = & 'chkdsk' $env:SystemDrive '/scan' '/perf' 2>&1 |
                    ForEach-Object {
                        [String]$Line = $_.TrimEnd()
                        if ($Line -match '\d+\s*%.*?(\d+)\s*%') {
                            Write-ActivityProgress ([Int]$Matches[1])
                        } elseif ($Line -ne '') {
                            if (($Line -match '^\S+\s+\d') -or ($Line -match '^Windows')) {
                                $LogLines.Add("`n$Line")
                            } else {
                                $LogLines.Add($Line)
                            }
                        }
                    }
                [Int]$ExitCode = $LASTEXITCODE
            } finally {
                [Console]::OutputEncoding = $PreviousEncoding
            }

            Set-Content -Path $LogPath -Value ($LogLines -join "`r`n") -Encoding UTF8 -Force -ErrorAction Stop
            Start-Process 'notepad.exe' -ArgumentList $LogPath -ErrorAction Stop

            # The scan itself ran, but a non-zero exit code means it found problems or could not finish
            if ($ExitCode -ne 0) {
                Write-LogWarning "Check Disk reported problems (exit code $ExitCode), see the log"
            }
            Write-ActivityCompleted
        }
    } catch {
        Out-Failure "Failed to start Check Disk: $_"
    }
}
