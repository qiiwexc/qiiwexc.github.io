Function Get-NetworkAdapter { Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True') }

Function Get-ConnectionStatus { if (!(Get-NetworkAdapter)) { Return 'Computer is not connected to the Internet' } }

Function Reset-StateOnExit { Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_TEMP_DIR; $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE; Write-Host '' }

Function Exit-Script { Reset-StateOnExit; $FORM.Close() }


Function Open-InBrowser {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$URL)

    Add-Log $INF "Opening URL in the default browser: $URL"

    try { [System.Diagnostics.Process]::Start($URL) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


Function Start-ExternalProcess {
    Param(
        [String[]][Parameter(Position = 0, Mandatory = $True)]$Commands,
        [String][Parameter(Position = 1)]$Title,
        [Switch]$Elevated,
        [Switch]$Wait,
        [Switch]$Hidden
    )

    if ($Title) { $Commands = , "(Get-Host).UI.RawUI.WindowTitle = '$Title'" + $Commands }
    Set-Variable -Option Constant FullCommand $([String]$($Commands | Where-Object { $_ -ne '' } | ForEach-Object { "$_;" }))

    Start-Process 'PowerShell' "-Command $FullCommand" -Wait:$Wait -Verb:$(if ($Elevated) { 'RunAs' } else { 'Open' }) -WindowStyle:$(if ($Hidden) { 'Hidden' } else { 'Normal' })
}
