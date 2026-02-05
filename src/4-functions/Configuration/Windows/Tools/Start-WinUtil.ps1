function Start-WinUtil {
    param(
        [Switch]$Personalisation,
        [Switch]$AutomaticallyApply
    )

    Write-LogInfo 'Starting WinUtil utility...'

    if (Find-RunningScript 'christitus.com') {
        Write-LogWarning 'WinUtil utility is already running'
        return
    }

    if (-not (Test-NetworkConnection)) {
        return
    }

    try {
        New-Directory $PATH_WINUTIL

        Set-Variable -Option Constant ConfigFile ([String]"$PATH_WINUTIL\WinUtil.json")

        [String]$Configuration = $CONFIG_WINUTIL
        if ($Personalisation) {
            $Configuration = $CONFIG_WINUTIL.Replace('    "WPFTweaks":  [
', '    "WPFTweaks":  [
' + $CONFIG_WINUTIL_PERSONALISATION)
        }

        Set-Content $ConfigFile $Configuration -NoNewline -ErrorAction Stop
    } catch {
        Write-LogWarning "Failed to initialize WinUtil configuration: $_"
    }

    try {
        Set-Variable -Option Constant ConfigParam ([String]" -Config $ConfigFile")

        if ($AutomaticallyApply) {
            Set-Variable -Option Constant RunParam ([String]' -Run')
        }

        Invoke-CustomCommand "& ([ScriptBlock]::Create((irm 'https://christitus.com/win')))$ConfigParam$RunParam"

        Out-Success
    } catch {
        Out-Failure "Failed to start WinUtil utility: $_"
    }
}
