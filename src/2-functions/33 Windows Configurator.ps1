Function Start-WindowsConfigurator {
    Add-Log $INF "Starting Windows configuration utility..."
    Start-Script "irm 'https://christitus.com/win' | iex"
    Out-Success
}
