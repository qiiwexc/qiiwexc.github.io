function Start-Executable {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Executable,
        [Parameter(Position = 1)][String]$Switches,
        [Switch]$Silent
    )

    Write-ActivityProgress 85

    # An executable runs as a process of its own name; a batch file runs as cmd, so its caller checks
    # for whatever it starts instead
    Set-Variable -Option Constant FileName ([String](Split-Path -Leaf $Executable -ErrorAction Stop))
    if ($FileName -match '\.exe$') {
        Set-Variable -Option Constant ProcessName ([String]($FileName -replace '\.exe$', ''))
        if (Find-RunningProcesses $ProcessName) {
            Write-LogWarning "Process '$ProcessName' is already running"
            return
        }
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
