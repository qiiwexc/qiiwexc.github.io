function Start-File {
    Param(
        [String][Parameter(Position = 0)]$Executable = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No executable specified"),
        [String][Parameter(Position = 1)]$Switches, [Switch]$SilentInstall
    )
    if (-not $Executable) { Return }

    if ($Switches -and $SilentInstall) {
        Add-Log $INF "Installing '$Executable' silently..."

        try { Start-Process "$CURRENT_DIR\$Executable" $Switches -Wait }
        catch [Exception] {
            Add-Log $ERR "Failed to install '$Executable': $($_.Exception.Message)"
            Return
        }

        Out-Success

        Add-Log $INF "Removing $Executable..."
        Remove-Item "$CURRENT_DIR\$Executable" -Force
        Out-Success
    }
    else {
        Add-Log $INF "Starting '$Executable'..."

        try {
            if ($Switches) { Start-Process "$CURRENT_DIR\$Executable" $Switches }
            elseif ($Executable -Match 'SDI_R*') { Start-Process "$CURRENT_DIR\$Executable" -WorkingDirectory "$CURRENT_DIR\$($Executable.Split('\')[0])" }
            else { Start-Process "$CURRENT_DIR\$Executable" }
        }
        catch [Exception] {
            Add-Log $ERR "Failed to execute '$Executable': $($_.Exception.Message)"
            Return
        }

        Out-Success
    }
}
