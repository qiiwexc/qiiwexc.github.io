function Start-Activator {
    Write-Log $INF 'Starting MAS activator...'

    if ($OS_VERSION -eq 7) {
        Invoke-Command -HideWindow "iex ((New-Object Net.WebClient).DownloadString('https://get.activated.win'))"
    } else {
        Invoke-Command -HideWindow "irm 'https://get.activated.win' | iex"
    }

    Out-Success
}
