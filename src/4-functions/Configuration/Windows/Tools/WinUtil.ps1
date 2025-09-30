function Start-WinUtil {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Personalisation,
        [Switch][Parameter(Position = 1, Mandatory = $True)]$AutomaticallyApply
    )

    Write-LogInfo 'Starting WinUtil utility...'

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if ($NoConnection) {
        Write-LogError "Failed to start: $NoConnection"
        return
    }

    New-Item -Force -ItemType Directory $PATH_WINUTIL | Out-Null

    Set-Variable -Option Constant ConfigFile "$PATH_WINUTIL\WinUtil.json"

    [String]$Configuration = $CONFIG_WINUTIL
    if ($Personalisation) {
        $Configuration = $CONFIG_WINUTIL.Replace('    "WPFTweaks":  [
', '    "WPFTweaks":  [
' + $CONFIG_WINUTIL_PERSONALISATION)
    }

    $Configuration | Out-File $ConfigFile

    Set-Variable -Option Constant ConfigParam "-Config $ConfigFile"
    Set-Variable -Option Constant RunParam $(if ($AutomaticallyApply) { '-Run' } else { '' })

    Invoke-CustomCommand "& ([ScriptBlock]::Create((irm 'https://christitus.com/win'))) $ConfigParam $RunParam"

    Out-Success
}
