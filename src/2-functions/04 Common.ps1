Function Get-NetworkAdapter {
    Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True')
}

Function Get-ConnectionStatus {
    if (!(Get-NetworkAdapter)) {
        Return 'Computer is not connected to the Internet'
    }
}

Function Reset-StateOnExit {
    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_TEMP_DIR
    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
    Write-Host ''
}

Function Exit-Script {
    Reset-StateOnExit
    $FORM.Close()
}


Function Open-InBrowser {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$URL)

    Add-Log $INF "Opening URL in the default browser: $URL"

    try {
        [System.Diagnostics.Process]::Start($URL)
    } catch [Exception] {
        Add-Log $ERR "Could not open the URL: $($_.Exception.Message)"
    }
}


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
