Function Get-FreeDiskSpace { Return ($SystemPartition.FreeSpace / $SystemPartition.Size) }

Function Get-NetworkAdapter { Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True') }

Function Get-ConnectionStatus { if (-not (Get-NetworkAdapter)) { Return 'Computer is not connected to the Internet' } }

Function Reset-StateOnExit { Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $TEMP_DIR; $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE; Write-Host '' }

Function Exit-Script { Reset-StateOnExit; $FORM.Close() }

Function Open-InBrowser {
    Param([String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"))
    if (-not $URL) { Return }

    Set-Variable -Option Constant UrlToOpen $(if ($URL -like 'http*') { $URL } else { 'https://' + $URL })
    Add-Log $INF "Opening URL in the default browser: $UrlToOpen"

    try { [System.Diagnostics.Process]::Start($UrlToOpen) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


Function Set-ButtonState {
    $BTN_UpdateOffice.Enabled = $OfficeInstallType -eq 'C2R'
    $BTN_HTTPSEverywhere.Enabled = $BTN_AdBlock.Enabled = Test-Path $ChromeExe
}

Function Start-ExternalProcess {
    Param(
        [String[]][Parameter(Position = 0)]$Commands = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No commands specified"),
        [String][Parameter(Position = 1)]$Title,
        [Switch]$Elevated, [Switch]$Wait, [Switch]$Hidden
    )
    if (-not $Commands) { Return }

    if ($Title) { $Commands = , "(Get-Host).UI.RawUI.WindowTitle = '$Title'" + $Commands }
    Set-Variable -Option Constant FullCommand $([String]$($Commands | ForEach-Object { "$_;" }))

    Start-Process 'PowerShell' "-Command $FullCommand" -Wait:$Wait -Verb:$(if ($Elevated) { 'RunAs' } else { 'Open' }) -WindowStyle:$(if ($Hidden) { 'Hidden' } else { 'Normal' })
}
