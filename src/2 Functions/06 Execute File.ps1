function Start-File ($FileName, $Switches, $IsSilentInstall) {
    $Executable = if ($FileName.Substring($FileName.Length - 4) -eq '.zip') {Start-Extraction $FileName} else {$FileName}

    if ($Switches -and $IsSilentInstall) {
        Add-Log $INF "Installing '$Executable' silently..."

        try {Start-Process "$CURRENT_DIR\$Executable" $Switches -Wait}
        catch [Exception] {
            Add-Log $ERR "Failed to install '$Executable': $($_.Exception.Message)"
            return
        }

        Out-Success

        Add-Log $INF "Removing $FileName..."
        Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore
        Out-Success
    }
    else {
        Add-Log $INF "Starting '$Executable'..."

        try {if ($Switches) {Start-Process "$CURRENT_DIR\$Executable" $Switches} else {Start-Process "$CURRENT_DIR\$Executable"}}
        catch [Exception] {
            Add-Log $ERR "Failed to execute' $Executable': $($_.Exception.Message)"
            return
        }

        Out-Success
    }
}
