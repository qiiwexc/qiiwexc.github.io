function Set-AnyDeskConfiguration {
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppName
    )

    try {
        Set-Variable -Option Constant ConfigPath ([String]"$env:AppData\$AppName\user.conf")

        if (Test-Path $ConfigPath) {
            Set-Variable -Option Constant CurrentConfig ([String](Get-Content $ConfigPath -Raw -Encoding UTF8 -ErrorAction Stop))
            Set-Variable -Option Constant NewKeys ([String[]]($CONFIG_ANYDESK -split '\r?\n' | Where-Object { $_ -match '=' } | ForEach-Object { ($_ -split '=', 2)[0] }))
            Set-Variable -Option Constant FilteredLines ([String[]]($CurrentConfig -split '\r?\n' | Where-Object {
                        [String]$key = ($_ -split '=', 2)[0]
                        $NewKeys -notcontains $key
                    }))
            Set-Variable -Option Constant MergedConfig ([String](($FilteredLines -join "`n") + $CONFIG_ANYDESK))
        } else {
            Set-Variable -Option Constant MergedConfig ([String]$CONFIG_ANYDESK)
        }

        Write-ConfigurationFile $AppName $MergedConfig -Path $ConfigPath

        Out-Success
    } catch {
        Out-Failure "Failed to configure '$AppName': $_"
    }
}
