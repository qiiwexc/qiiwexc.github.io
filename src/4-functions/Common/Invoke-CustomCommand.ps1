function Invoke-CustomCommand {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Command,
        [String]$WorkingDirectory,
        [Switch]$Elevated,
        [Switch]$HideWindow
    )

    if ($WorkingDirectory) {
        Set-Variable -Option Constant WorkingDir ([String]"-WorkingDirectory $WorkingDirectory")
    }

    if ($Elevated) {
        Set-Variable -Option Constant Verb ([String]'RunAs')
    } else {
        Set-Variable -Option Constant Verb ([String]'Open')
    }

    if ($HideWindow) {
        Set-Variable -Option Constant WindowStyle ([String]'Hidden')
    } else {
        Set-Variable -Option Constant WindowStyle ([String]'Normal')
    }

    Set-Variable -Option Constant FullCommand ([String]"$Command $WorkingDir")
    Start-Process PowerShell $FullCommand -Verb $Verb -WindowStyle $WindowStyle -ErrorAction Stop
}
