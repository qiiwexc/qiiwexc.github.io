# Not every power setting exists on every machine: some lack the one for sharing media, for instance. powercfg fails
# on a missing one, through its exit code or, under the Stop preference, by throwing
function Test-PowerSetting {
    param(
        [Parameter(Position = 0, Mandatory)][String]$SubGroup,
        [Parameter(Position = 1, Mandatory)][String]$Setting
    )

    try {
        powercfg /Query SCHEME_CURRENT $SubGroup $Setting 2>$Null | Out-Null
        return $LASTEXITCODE -eq 0
    } catch {
        return $False
    }
}
