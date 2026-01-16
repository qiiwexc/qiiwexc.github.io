function Update-WebDependency {
    param(
        [PSCustomObject][Parameter(Position = 0, Mandatory)]$Dependency
    )

    Set-Variable -Option Constant Uri ([String]$Dependency.url)

    Write-LogInfo "Fetching URL: $Uri" 1

    try {
        Set-Variable -Option Constant Response ([PSCustomObject](Invoke-WebRequest $Uri -UseBasicParsing))
    } catch {
        Write-LogError "Failed to fetch URL '$Uri': $_" 1
        return
    }

    if (-not $Response.Content) {
        Write-LogError "No data fetched from URL '$Uri'" 1
        return
    }

    Set-Variable -Option Constant Matches ([regex]::Matches($Response.Content, $Dependency.regex, @('IgnoreCase', 'Multiline')))

    if ($Matches.Count -eq 0) {
        Write-LogError "Failed to find version number from URL '$Uri'" 1
        return
    }

    Set-Variable -Option Constant LatestVersion ([String]($Matches[0].Groups[1].Value))

    if ($LatestVersion -ne '' -and $LatestVersion -ne $Dependency.version) {
        Set-NewVersion $Dependency $LatestVersion
        return @($Uri)
    }
}
