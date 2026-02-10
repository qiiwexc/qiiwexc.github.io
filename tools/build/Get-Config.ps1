function Get-Config {
    param(
        [String][Parameter(Position = 0, Mandatory)]$BuildPath,
        [Version][Parameter(Position = 1, Mandatory)]$Version
    )

    New-Activity 'Loading config'

    Set-Variable -Option Constant UrlsFile ([String]"$BuildPath\urls.json")

    [Collections.Generic.List[Config]]$Config = Read-JsonFile $UrlsFile

    $Config.Add(@{key = 'PROJECT_VERSION'; value = $Version })

    Write-ActivityCompleted

    return $Config
}
