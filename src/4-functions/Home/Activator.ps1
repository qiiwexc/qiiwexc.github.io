function Start-Activator {
    Write-LogInfo 'Starting MAS activator...'

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if ($NoConnection) {
        Write-LogError "Failed to start: $NoConnection"
        return
    }

    if ($OS_VERSION -eq 7) {
        Invoke-CustomCommand -HideWindow "iex ((New-Object Net.WebClient).DownloadString('https://get.activated.win'))"
    } else {
        Invoke-CustomCommand -HideWindow "irm 'https://get.activated.win' | iex"
    }

    Out-Success
}
