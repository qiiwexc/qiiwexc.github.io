function Set-AnyDeskConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    try {
        Set-Variable -Option Constant ConfigPath ([String]"$env:AppData\$AppName\user.conf")

        if (Test-Path $ConfigPath) {
            Set-Variable -Option Constant CurrentConfig ([String](Get-Content $ConfigPath -Raw -Encoding UTF8 -ErrorAction Stop))
        } else {
            Set-Variable -Option Constant CurrentConfig ([String]'')
        }

        Write-ConfigurationFile $AppName ($CurrentConfig + $CONFIG_ANYDESK) -Path $ConfigPath

        Out-Success
    } catch {
        Out-Failure "Failed to configure '$AppName': $_"
    }
}
