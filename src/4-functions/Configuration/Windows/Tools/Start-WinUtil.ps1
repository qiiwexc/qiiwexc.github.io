function Start-WinUtil {
    Write-LogInfo 'Starting WinUtil utility...'

    if (-not (Test-NetworkConnection)) {
        return
    }

    try {
        New-Directory $PATH_WINUTIL

        Set-Variable -Option Constant ConfigFile ([String]"$PATH_WINUTIL\WinUtil.json")

        Set-Content $ConfigFile $CONFIG_WINUTIL -NoNewline -ErrorAction Stop
    } catch {
        Write-LogWarning "Failed to initialize WinUtil configuration: $_"
    }

    try {
        Invoke-CustomCommand "& ([ScriptBlock]::Create((irm 'https://christitus.com/win'))) -Config $ConfigFile"

        Out-Success
    } catch {
        Out-Failure "Failed to start WinUtil utility: $_"
    }
}
