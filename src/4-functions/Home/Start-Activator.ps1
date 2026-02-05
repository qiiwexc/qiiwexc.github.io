function Start-Activator {
    param(
        [Switch]$ActivateWindows,
        [Switch]$ActivateOffice
    )

    try {
        Write-LogInfo 'Starting MAS activator...'

        if (Find-RunningScript 'get.activated.win') {
            Write-LogWarning 'MAS activator is already running'
            return
        }

        if (-not (Test-NetworkConnection)) {
            return
        }

        [String]$Params = ''

        if ($ActivateWindows) {
            $Params += ' /HWID'
        }

        if ($ActivateOffice) {
            $Params += ' /Ohook'
        }

        Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://get.activated.win')))$Params"

        Out-Success
    } catch {
        Out-Failure "Failed to start MAS activator: $_"
    }
}
