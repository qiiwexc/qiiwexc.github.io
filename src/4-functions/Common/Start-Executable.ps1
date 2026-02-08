function Start-Executable {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Executable,
        [String][Parameter(Position = 1)]$Switches,
        [Switch]$Silent
    )

    Write-ActivityProgress 85

    Set-Variable -Option Constant ProcessName ([String](Split-Path -Leaf $Executable -ErrorAction Stop) -replace '\.exe$', '')
    if (Find-RunningProcesses $ProcessName) {
        Write-LogWarning "Process '$ProcessName' is already running"
        return
    }

    if ($Switches -and $Silent) {
        Write-ActivityProgress 90 "Running '$Executable' silently..."
        Start-Process -Wait $Executable $Switches -ErrorAction Stop
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
