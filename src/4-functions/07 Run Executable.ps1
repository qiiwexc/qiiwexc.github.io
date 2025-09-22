Function Start-Executable {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Executable,
        [String][Parameter(Position = 1)]$Switches,
        [Switch]$Silent
    )

    if ($Switches -and $Silent) {
        Write-Log $INF "Running '$Executable' silently..."

        try {
            Start-Process -Wait $Executable $Switches
        } catch [Exception] {
            Write-ExceptionLog $_ "Failed to run '$Executable'"
            Return
        }

        Out-Success

        Write-Log $INF "Removing '$Executable'..."
        Remove-Item -Force $Executable
        Out-Success
    } else {
        Write-Log $INF "Running '$Executable'..."

        try {
            if ($Switches) {
                Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable)
            } else {
                Start-Process $Executable -WorkingDirectory (Split-Path $Executable)
            }
        } catch [Exception] {
            Write-ExceptionLog $_ "Failed to execute '$Executable'"
            Return
        }

        Out-Success
    }
}
