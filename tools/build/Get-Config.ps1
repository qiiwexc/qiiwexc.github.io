function Get-Config {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ResourcesPath,
        [Parameter(Position = 1, Mandatory)][Version]$Version
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

        if ($Config.PSObject.Properties[$Key]) {
            $Config.$Key = $Config.$Key.Replace('{VERSION}', $DepVersion)
        }
    }

    $Config | Add-Member -NotePropertyName 'PROJECT_VERSION' -NotePropertyValue $Version -Force

    Write-ActivityCompleted

    return $Config
}
