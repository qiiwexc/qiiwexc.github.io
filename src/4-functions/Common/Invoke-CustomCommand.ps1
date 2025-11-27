function Invoke-CustomCommand {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Command,
        [String]$WorkingDirectory,
        [Switch]$BypassExecutionPolicy,
        [Switch]$Elevated,
        [Switch]$HideWindow,
        [Switch]$Wait
    )

    if ($BypassExecutionPolicy) {
        Set-Variable -Option Constant ExecutionPolicy ([String]'-ExecutionPolicy Bypass')
    }

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

    Set-Variable -Option Constant FullCommand ([String]"$ExecutionPolicy $Command $WorkingDir")
    Start-Process PowerShell $FullCommand -Wait:$Wait -Verb $Verb -WindowStyle $WindowStyle
}
