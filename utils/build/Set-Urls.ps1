function Set-Urls {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigPath,
        [String][Parameter(Position = 1, Mandatory)]$TemplatesPath,
        [String][Parameter(Position = 2, Mandatory)]$BuildPath
    )

    Write-LogInfo 'Setting URLs...'

    Set-Variable -Option Constant DependenciesFile ([String]"$ConfigPath\dependencies.json")
    Set-Variable -Option Constant TemplateFile ([String]"$TemplatesPath\urls.json")
    Set-Variable -Option Constant OutputFile ([String]"$BuildPath\urls.json")

    [Collections.Generic.List[Object]]$Dependencies = Get-Content $DependenciesFile | ConvertFrom-Json
    [Collections.Generic.List[Object]]$TemplateContent = Get-Content $TemplateFile | ConvertFrom-Json

    foreach ($Dependency in $Dependencies) {
        [String]$Name = $Dependency.name.ToUpper().Replace(' ', '_').Replace('-', '_')
        [String]$Version = $Dependency.version.TrimStart('v')

        foreach ($Entry in $TemplateContent) {
            if ($Name -eq $Entry.key.Replace('URL_', '')) {
                $Entry.value = $Entry.value.Replace('{VERSION}', $Version)
            }
        }
    }

    $TemplateContent | ConvertTo-Json | Out-File $OutputFile -Encoding UTF8

    Out-Success
}
