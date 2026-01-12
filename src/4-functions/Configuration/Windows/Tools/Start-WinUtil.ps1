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

    New-Item -Force -ItemType Directory $PATH_WINUTIL | Out-Null

    Set-Variable -Option Constant ConfigFile ([String]"$PATH_WINUTIL\WinUtil.json")

    [String]$Configuration = $CONFIG_WINUTIL
    if ($Personalisation) {
        $Configuration = $CONFIG_WINUTIL.Replace('    "WPFTweaks":  [
', '    "WPFTweaks":  [
' + $CONFIG_WINUTIL_PERSONALISATION)
    }

    $Configuration | Set-Content $ConfigFile -NoNewline

    Set-Variable -Option Constant ConfigParam ([String]"-Config $ConfigFile")

    if ($AutomaticallyApply) {
        Set-Variable -Option Constant RunParam ([String]'-Run')
    }

    Invoke-CustomCommand "& ([ScriptBlock]::Create((irm 'https://christitus.com/win'))) $ConfigParam $RunParam"

    Out-Success
}
