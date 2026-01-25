function Start-Executable {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Executable,
        [String][Parameter(Position = 1)]$Switches,
        [Switch]$Silent
    )

    if ($Switches -and $Silent) {
        Write-ActivityProgress 90 "Running '$Executable' silently..."
        Start-Process -Wait $Executable $Switches -ErrorAction Stop
        Out-Success

        Write-LogDebug "Removing '$Executable'..."
        Remove-File $Executable -Silent
        Out-Success
    } else {
        Write-ActivityProgress 90 "Running '$Executable'..."

        if ($Switches) {
            Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable) -ErrorAction Stop
        } else {
            Start-Process $Executable -WorkingDirectory (Split-Path $Executable) -ErrorAction Stop
        }
    }
}
