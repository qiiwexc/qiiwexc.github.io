function Start-WinUtil {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Apply
    )

    Write-LogInfo 'Starting WinUtil utility...'

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if ($NoConnection) {
        Write-LogError "Failed to start: $NoConnection"
        return
    }

    New-Item -Force -ItemType Directory $PATH_WINUTIL | Out-Null

    Set-Variable -Option Constant ConfigFile "$PATH_WINUTIL\WinUtil.json"

    $CONFIG_WINUTIL | Out-File $ConfigFile

    Set-Variable -Option Constant ConfigParam "-Config $ConfigFile"
    Set-Variable -Option Constant RunParam $(if ($Apply) { '-Run' } else { '' })

    Invoke-CustomCommand "& ([ScriptBlock]::Create((irm 'https://christitus.com/win'))) $ConfigParam $RunParam"

    Out-Success
}
