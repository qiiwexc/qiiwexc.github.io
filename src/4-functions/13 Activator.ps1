Function Start-Activator {
    Write-Log $INF "Starting MAS activator..."

    if ($OS_VERSION -eq 7) {
        Start-Script -HideWindow "iex ((New-Object Net.WebClient).DownloadString('https://get.activated.win'))"
    } else {
        Start-Script -HideWindow "irm https://get.activated.win | iex"
    }

    Out-Success
}
