function Start-Executable {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Executable,
        [String][Parameter(Position = 1)]$Switches,
        [Switch]$Silent
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    if ($Switches -and $Silent) {
        Write-ActivityProgress 90 "Running '$Executable' silently..."

        try {
            Start-Process -Wait $Executable $Switches -ErrorAction Stop
        } catch {
            Write-LogError "Failed to run '$Executable': $_" $LogIndentLevel
            return
        }

        Out-Success $LogIndentLevel

        Write-LogDebug "Removing '$Executable'..." $LogIndentLevel
        Remove-File $Executable
        Out-Success $LogIndentLevel
    } else {
        Write-ActivityProgress 90 "Running '$Executable'..."

        try {
            if ($Switches) {
                Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable) -ErrorAction Stop
            } else {
                Start-Process $Executable -WorkingDirectory (Split-Path $Executable) -ErrorAction Stop
            }
        } catch {
            Write-LogError "Failed to execute '$Executable': $_" $LogIndentLevel
            return
        }

        Out-Success $LogIndentLevel
    }
}
