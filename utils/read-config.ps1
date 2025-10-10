function Get-Config {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AssetsPath,
        [String][Parameter(Position = 1, Mandatory = $True)]$Version
    )

    Write-LogInfo 'Loading config...'

    Set-Variable -Option Constant UrlsFile "$AssetsPath\urls.json"

    [Collections.Generic.List[Object]]$Config = Get-Content $UrlsFile | ConvertFrom-Json
    $Config.Add(@{key = 'PROJECT_VERSION'; value = $Version })

    Out-Success

    return $Config
}
