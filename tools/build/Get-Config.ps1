function Get-Config {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ResourcesPath,
        [Version][Parameter(Position = 1, Mandatory)]$Version
    )

    New-Activity 'Loading config'

    Set-Variable -Option Constant DependenciesFile ([String]"$ResourcesPath\dependencies.json")
    Set-Variable -Option Constant UrlsFile ([String]"$ResourcesPath\urls.json")

    [Dependency[]]$Dependencies = Read-JsonFile $DependenciesFile
    [PSCustomObject]$Config = Read-JsonFile $UrlsFile

    foreach ($Dependency in $Dependencies) {
        [String]$Name = $Dependency.name.ToUpper().Replace(' ', '_').Replace('-', '_')
        [String]$DepVersion = $Dependency.version.TrimStart('v')
        [String]$Key = "URL_$Name"

        if ($null -ne $Config.$Key) {
            $Config.$Key = $Config.$Key.Replace('{VERSION}', $DepVersion)
        }
    }

    $Config | Add-Member -NotePropertyName 'PROJECT_VERSION' -NotePropertyValue $Version

    Write-ActivityCompleted

    return $Config
}
