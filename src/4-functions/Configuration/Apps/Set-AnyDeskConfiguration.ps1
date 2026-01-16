function Set-AnyDeskConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    try {
        Write-ActivityProgress -PercentComplete 5 -Task "Configuring $AppName..."

        Set-Variable -Option Constant ConfigPath ([String]"$env:AppData\$AppName\user.conf")

        if (Test-Path $ConfigPath) {
            Set-Variable -Option Constant CurrentConfig ([String](Get-Content $ConfigPath -Raw -Encoding UTF8))
        } else {
            Set-Variable -Option Constant CurrentConfig ([String]'')
        }

        Write-ConfigurationFile $AppName ($CurrentConfig + $CONFIG_ANYDESK) $ConfigPath
    } catch {
        Write-LogError "Failed to configure '$AppName': $_"
    }
}
