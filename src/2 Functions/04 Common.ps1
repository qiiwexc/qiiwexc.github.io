function Open-InBrowser {
    Param([String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"))
    if (-not $URL) { Return }

    Set-Variable UrlToOpen $(if ($URL -like 'http*') { $URL } else { 'https://' + $URL }) -Option Constant
    Add-Log $INF "Opening URL in the default browser: $UrlToOpen"

    try { [System.Diagnostics.Process]::Start($UrlToOpen) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


function Set-ButtonState {
    $BTN_UpdateOffice.Enabled = $BTN_OfficeInsider.Enabled = $OfficeInstallType -eq 'C2R'
    $BTN_RunCCleaner.Enabled = Test-Path $CCleanerExe
    $BTN_RunDefraggler.Enabled = Test-Path $DefragglerExe
    $BTN_GoogleUpdate.Enabled = Test-Path $GoogleUpdateExe
}


function Get-FreeDiskSpace { Return ($SystemPartition.FreeSpace / $SystemPartition.Size) }

function Get-NetworkAdapter { Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True') }

function Get-ConnectionStatus { if (-not (Get-NetworkAdapter)) { Return 'Computer is not connected to the Internet' } }

function Reset-CmdWindow { $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE; Write-Host '' }

function Exit-Script { Reset-CmdWindow; $FORM.Close() }
