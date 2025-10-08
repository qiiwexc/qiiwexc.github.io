function Start-Executable {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Executable,
        [String][Parameter(Position = 1)]$Switches,
        [Switch]$Silent
    )

    if ($Switches -and $Silent) {
        Write-ActivityProgress -PercentComplete 90 -Task "Running '$Executable' silently..."

        try {
            Start-Process -Wait $Executable $Switches
        } catch [Exception] {
            Write-ExceptionLog $_ "Failed to run '$Executable'"
            return
        }

        Out-Success

        Write-LogDebug "Removing '$Executable'..."
        Remove-File $Executable
        Out-Success
    } else {
        Write-ActivityProgress -PercentComplete 90 -Task "Running '$Executable'..."

        try {
            if ($Switches) {
                Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable)
            } else {
                Start-Process $Executable -WorkingDirectory (Split-Path $Executable)
            }
        } catch [Exception] {
            Write-ExceptionLog $_ "Failed to execute '$Executable'"
            return
        }

        Out-Success
    }
}
