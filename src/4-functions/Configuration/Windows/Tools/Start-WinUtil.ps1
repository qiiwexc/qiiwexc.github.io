function Start-WinUtil {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$Personalisation,
        [Switch][Parameter(Position = 1, Mandatory)]$AutomaticallyApply
    )

    Write-LogInfo 'Starting WinUtil utility...'

    Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
    if (-not $IsConnected) {
        return
    }

    try {
        $Null = New-Item -Force -ItemType Directory $PATH_WINUTIL -ErrorAction Stop

        Set-Variable -Option Constant ConfigFile ([String]"$PATH_WINUTIL\WinUtil.json")

        if ($Personalisation) {
            Set-Variable -Option Constant Configuration ([String]$CONFIG_WINUTIL.Replace('    "WPFTweaks":  [
', '    "WPFTweaks":  [
    "WPFTweaksRightClickMenu",
'))
        } else {
            Set-Variable -Option Constant Configuration ([String]$CONFIG_WINUTIL)
        }

        $Configuration | Set-Content $ConfigFile -NoNewline -ErrorAction Stop
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
