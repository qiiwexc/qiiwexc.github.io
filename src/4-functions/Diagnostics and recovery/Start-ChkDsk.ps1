function Start-ChkDsk {
    param(
        [Switch]$ScheduleFullScan
    )

    try {
        if ($ScheduleFullScan) {
            Write-LogInfo 'Scheduling full Check Disk scan...'
            Start-Process 'cmd' -ArgumentList '/c "echo y | chkdsk /f /r"' -NoNewWindow -Wait -ErrorAction Stop
            Write-LogWarning 'Full disc scan scheduled. Please restart your computer to allow Check Disk to run before Windows starts.'
            Out-Success
        } else {
            New-Activity 'Checking Disk'

            Initialize-AppDirectory
            Set-Variable -Option Constant LogPath ([String]"$PATH_APP_DIR\chkdsk.log")

            [Collections.Generic.List[String]]$LogLines = @()
            $Null = & 'chkdsk' '/scan' '/perf' 2>&1 |
            ForEach-Object {
                [String]$Line = $_.TrimEnd()
                if ($Line -match '^Progress:') {
                    if ($Line -match 'Total:\s*(\d+)%') {
                        Write-ActivityProgress ([Int]$Matches[1])
                    }
                } elseif ($Line -ne '') {
                    if (($Line -match '^Stage') -or ($Line -match '^Windows')) {
                        $LogLines.Add("`n$Line")
                    } else {
                        $LogLines.Add($Line)
                    }
                }
            }

            Set-Content -Path $LogPath -Value ($LogLines -join "`r`n") -Encoding UTF8 -Force -ErrorAction Stop
            Start-Process 'notepad.exe' -ArgumentList $LogPath -ErrorAction Stop
            Write-ActivityCompleted
        }
    } catch {
        Out-Failure "Failed to start Check Disk: $_"
    }
}
