function Start-Executable {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Executable,
        [String][Parameter(Position = 1)]$Switches,
        [Switch]$Silent
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    if ($Switches -and $Silent) {
        Write-ActivityProgress -PercentComplete 90 -Task "Running '$Executable' silently..."

        try {
            Start-Process -Wait $Executable $Switches
        } catch [Exception] {
            Write-LogException $_ "Failed to run '$Executable'" $LogIndentLevel
            return
        }

        Out-Success $LogIndentLevel

        Write-LogDebug "Removing '$Executable'..." $LogIndentLevel
        Remove-File $Executable
        Out-Success $LogIndentLevel
    } else {
        Write-ActivityProgress -PercentComplete 90 -Task "Running '$Executable'..."

        try {
            if ($Switches) {
                Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable)
            } else {
                Start-Process $Executable -WorkingDirectory (Split-Path $Executable)
            }
        } catch [Exception] {
            Write-LogException $_ "Failed to execute '$Executable'" $LogIndentLevel
            return
        }

        Out-Success $LogIndentLevel
    }
}
