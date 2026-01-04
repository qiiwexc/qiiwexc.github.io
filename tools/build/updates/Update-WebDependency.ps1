function Update-WebDependency {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Dependency
    )

    Set-Variable -Option Constant Uri ([String]$Dependency.url)

    Write-LogInfo "Fetching URL: $Uri" 1

    Set-Variable -Option Constant Response ([Object](Invoke-WebRequest $Uri -UseBasicParsing))

    if (-not $Response.Content) {
        Write-LogError "Failed to fetch URL: $Uri" 1
        return
    }

    Set-Variable -Option Constant Matches ([regex]::Matches($Response.Content, $Dependency.regex, @('IgnoreCase', 'Multiline')))
    Set-Variable -Option Constant LatestVersion ([String]($Matches | Select-Object -First 1).Groups[1].Value)

    if ($LatestVersion -ne $Dependency.version) {
        Set-NewVersion $Dependency $LatestVersion
        return @($Uri)
    }
}
