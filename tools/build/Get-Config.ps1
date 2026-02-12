function Get-Config {
    param(
        [String][Parameter(Position = 0, Mandatory)]$BuildPath,
        [Version][Parameter(Position = 1, Mandatory)]$Version
    )

    New-Activity 'Loading config'

    Set-Variable -Option Constant UrlsFile ([String]"$BuildPath\urls.json")

    [PSCustomObject]$Config = Read-JsonFile $UrlsFile

    $Config | Add-Member -NotePropertyName 'PROJECT_VERSION' -NotePropertyValue $Version

    Write-ActivityCompleted

    return $Config
}
