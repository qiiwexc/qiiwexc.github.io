function Start-Activator {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$ActivateWindows,
        [Switch][Parameter(Position = 1, Mandatory)]$ActivateOffice
    )

    Write-LogInfo 'Starting MAS activator...'

    Set-Variable -Option Constant NoConnection ([String](Test-NetworkConnection))
    if ($NoConnection) {
        Write-LogError "Failed to start: $NoConnection"
        return
    }

    [String]$Params = ''

    if ($ActivateWindows) {
        $Params += ' /HWID'
    }

    if ($ActivateOffice) {
        $Params += ' /Ohook'
    }

    if ($OS_VERSION -eq 7) {
        Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((New-Object Net.WebClient).DownloadString('https://get.activated.win'))) $Params"
    } else {
        Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm https://get.activated.win))) $Params"
    }

    Out-Success
}
