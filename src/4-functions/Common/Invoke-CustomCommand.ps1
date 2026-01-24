function Invoke-CustomCommand {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Command,
        [Switch]$Elevated,
        [Switch]$HideWindow
    )

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

    Start-Process PowerShell $Command -Verb $Verb -WindowStyle $WindowStyle -ErrorAction Stop
}
