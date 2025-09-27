function Start-WinUtil {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Apply
    )

    Write-LogInfo 'Starting WinUtil utility...'

    Set-Variable -Option Constant ConfigFile "$PATH_APP_DIR\winutil.json"

    $CONFIG_WINUTIL | Out-File $ConfigFile

    Set-Variable -Option Constant ConfigParam "-Config $ConfigFile"
    Set-Variable -Option Constant RunParam $(if ($Apply) { '-Run' } else { '' })

    Invoke-CustomCommand "& ([ScriptBlock]::Create((irm 'https://christitus.com/win'))) $ConfigParam $RunParam"

    Out-Success
}
