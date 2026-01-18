function Get-Config {
    param(
        [String][Parameter(Position = 0, Mandatory)]$BuildPath,
        [String][Parameter(Position = 1, Mandatory)]$Version
    )

    New-Activity 'Loading config'

    Set-Variable -Option Constant UrlsFile ([String]"$BuildPath\urls.json")

    [Collections.Generic.List[PSCustomObject]]$Config = Get-Content $UrlsFile -Raw -Encoding UTF8 | ConvertFrom-Json

    $Config.Add(@{key = 'PROJECT_VERSION'; value = $Version })

    Write-ActivityCompleted

    return $Config
}
