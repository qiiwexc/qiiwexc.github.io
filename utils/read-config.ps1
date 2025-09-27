#Requires -PSEdition Desktop
#Requires -Version 3

function Get-Config {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AssetsPath,
        [String][Parameter(Position = 1, Mandatory = $True)]$Version
    )

    Write-LogInfo 'Loading config...'

    Set-Variable -Option Constant UrlsFile "$AssetsPath\urls.json"

    [System.Object[]]$Config = Get-Content $UrlsFile | ConvertFrom-Json
    $Config += @{key = 'PROJECT_VERSION'; value = $Version }

    Out-Success

    return $Config
}
