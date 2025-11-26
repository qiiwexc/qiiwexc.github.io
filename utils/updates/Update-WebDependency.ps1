function Update-WebDependency {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Dependency
    )

    Set-Variable -Option Constant Uri $Dependency.url

    Write-LogInfo "Fetching URL: $Uri" 1

    Set-Variable -Option Constant Response (Invoke-WebRequest $Uri).Content
    Set-Variable -Option Constant Matches ([regex]::Matches($Response, $Dependency.regex, @('IgnoreCase', 'Multiline')))
    Set-Variable -Option Constant LatestVersion ($Matches | Select-Object -First 1).Groups[1].Value

    if ($LatestVersion -ne $Dependency.version) {
        Set-NewVersion $Dependency $LatestVersion
        return @($Uri)
    }
}
