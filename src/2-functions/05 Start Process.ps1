Function Start-ExternalProcess {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Command,
        [Switch]$BypassExecutionPolicy,
        [Switch]$Elevated,
        [Switch]$HideConsole,
        [Switch]$HideWindow,
        [Switch]$Wait
    )

    Set-Variable -Option Constant ExecutionPolicy $(if ($BypassExecutionPolicy) { '-ExecutionPolicy Bypass' } else { '' })
    Set-Variable -Option Constant ConsoleState $(if ($HideConsole) { '-HideConsole' } else { '' })
    Set-Variable -Option Constant Verb $(if ($Elevated) { 'RunAs' } else { 'Open' })
    Set-Variable -Option Constant WindowStyle $(if ($HideWindow) { 'Hidden' } else { 'Normal' })

    Set-Variable -Option Constant FullCommand "$ExecutionPolicy $Command $ConsoleState"

    Start-Process 'PowerShell' $FullCommand -Wait:$Wait -Verb:$Verb -WindowStyle:$WindowStyle
}
