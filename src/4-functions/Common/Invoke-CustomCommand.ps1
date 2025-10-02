function Invoke-CustomCommand {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Command,
        [String]$WorkingDirectory,
        [Switch]$BypassExecutionPolicy,
        [Switch]$Elevated,
        [Switch]$HideWindow,
        [Switch]$Wait
    )

    Set-Variable -Option Constant ExecutionPolicy $(if ($BypassExecutionPolicy) { '-ExecutionPolicy Bypass' } else { '' })
    Set-Variable -Option Constant WorkingDir $(if ($WorkingDirectory) { "-WorkingDirectory:$WorkingDirectory" } else { '' })
    Set-Variable -Option Constant Verb $(if ($Elevated) { 'RunAs' } else { 'Open' })
    Set-Variable -Option Constant WindowStyle $(if ($HideWindow) { 'Hidden' } else { 'Normal' })

    Set-Variable -Option Constant FullCommand "$ExecutionPolicy $Command $WorkingDir"

    Start-Process PowerShell $FullCommand -Wait:$Wait -Verb:$Verb -WindowStyle:$WindowStyle
}
