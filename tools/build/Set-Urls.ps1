function Set-Urls {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigPath,
        [String][Parameter(Position = 1, Mandatory)]$TemplatesPath,
        [String][Parameter(Position = 2, Mandatory)]$BuildPath
    )

    New-Activity 'Setting URLs'

    Set-Variable -Option Constant DependenciesFile ([String]"$ConfigPath\dependencies.json")
    Set-Variable -Option Constant TemplateFile ([String]"$TemplatesPath\urls.json")
    Set-Variable -Option Constant OutputFile ([String]"$BuildPath\urls.json")

    [Dependency[]]$Dependencies = Read-JsonFile $DependenciesFile
    [PSCustomObject]$TemplateContent = Read-JsonFile $TemplateFile

    foreach ($Dependency in $Dependencies) {
        [String]$Name = $Dependency.name.ToUpper().Replace(' ', '_').Replace('-', '_')
        [String]$Version = $Dependency.version.TrimStart('v')
        [String]$Key = "URL_$Name"

        if ($null -ne $TemplateContent.$Key) {
            $TemplateContent.$Key = $TemplateContent.$Key.Replace('{VERSION}', $Version)
        }
    }

    Write-JsonFile $OutputFile $TemplateContent

    Write-ActivityCompleted
}
